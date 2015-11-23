class CheckDaysStoredProcedure < ActiveRecord::Migration
  def self.up
	 execute <<-__EOI
	  CREATE OR REPLACE FUNCTION check_days(local_id int, provider_ids int[], serv_ids int[], start_date date, end_date date)
		returns TABLE(day_date date, available_day boolean)
		AS 
		$$
		DECLARE
		  now_date date;
		  now_start timestamp;
		  now_end timestamp;
		  now_start_next timestamp;
		  now_end_next timestamp;
		  after_time timestamp;
		  before_time timestamp;
		  p_id int;
		  available_block boolean;
		  any_available boolean;
		BEGIN

		  IF (select array_length(provider_ids, 1)) != (select array_length(serv_ids, 1)) OR array_length(provider_ids, 1) <= 0 THEN
		    RETURN;
		  END IF;

		  now_date := start_date;
		  before_time := localtimestamp + ((select before_booking from company_settings where company_settings.company_id = (select company_id from locations where locations.id = local_id)) * interval '1 hour');
		  after_time := localtimestamp + ((select after_booking from company_settings where company_settings.company_id = (select company_id from locations where locations.id = local_id)) * interval '1 month');

		  <<month_loop>>
		  LOOP
		    available_day := FALSE;
		    -- RAISE NOTICE 'now_date: %', to_char(now_date, 'YYYY-MM-DD');
		    -- RAISE NOTICE 'current_start: %', to_char(current_start, 'YYYY-MM-DD HH24:MI:SS');
		    now_start := now_date + (select open from location_times where location_times.location_id = local_id and location_times.day_id = extract(dow from now_date) order by open);
			  --Check after and before settings
			  IF now_start > before_time AND now_start < after_time THEN
			    IF exists (select id from location_times where location_times.location_id = local_id and location_times.day_id = extract(dow from now_date)) THEN
		        <<day_loop>>
		        LOOP
		    	  now_start_next := now_start;
		          -- RAISE NOTICE 'now_start_first: %', to_char(now_start, 'YYYY-MM-DD HH24:MI:SS');
		          available_block := TRUE;
		          <<providers_services_loop>>
		          FOR i IN 1 .. ( select array_length(provider_ids, 1)) LOOP
		            now_end_next := now_start_next + ((select duration from services where services.id = serv_ids[i]) * interval '1 minute');
		          -- RAISE NOTICE 'provider: %', provider_ids[i];
		          -- RAISE NOTICE 'service: %', serv_ids[i];
		          -- RAISE NOTICE 'now_start: %', to_char(now_start_next, 'YYYY-MM-DD HH24:MI:SS');
		          -- RAISE NOTICE 'now_end: %', to_char(now_end_next, 'YYYY-MM-DD HH24:MI:SS');
		            IF (select provider_ids[i]) = 0 THEN
		              any_available := FALSE;
		              <<providers_loop>>
		              FOR p_id IN (select id from (select id, provider_occupation(id, now_date, now_date) from service_providers where active = true AND online_booking = true AND id IN (select service_provider_id from service_staffs where service_id = serv_ids[i]) AND id IN (select service_provider_id from provider_times where day_id = extract(dow from now_date)) ORDER BY provider_occupation(id, now_date, now_date)) AS elegible_providers) LOOP
		                IF check_hour(local_id, p_id, serv_ids[i], now_start_next, now_end_next) THEN
		                  any_available := TRUE;
		                END IF;
		         		-- RAISE NOTICE 'any_available: %', any_available;
		                EXIT providers_loop WHEN any_available = TRUE;
		              END LOOP providers_loop;
		              IF not any_available THEN
		                available_block := FALSE;
		              END IF;
		            ELSE
		              IF NOT check_hour(local_id, provider_ids[i], serv_ids[i], now_start_next, now_end_next) THEN
		                available_block := FALSE;
		              END IF;
		            END IF;
		            EXIT providers_services_loop WHEN available_block = FALSE;
		            now_start_next := now_end_next;
		          END LOOP providers_services_loop;
		          now_start := now_start + (5 * interval '1 minute');
		          IF available_block THEN
		            available_day := available_block;
		          END IF;
		          EXIT day_loop WHEN available_day = TRUE;
		          EXIT day_loop WHEN now_end_next > (now_date + (select close from location_times where location_times.location_id = local_id and location_times.day_id = extract(dow from now_date) order by close desc));
		        END LOOP day_loop;
			    END IF;
			  END IF;
		    day_date := now_date;
		    RETURN NEXT;
		    now_date := now_date + 1;
		    EXIT month_loop WHEN now_date > end_date;
		  END LOOP month_loop;
		END
		$$ LANGUAGE plpgsql;
	  __EOI
	end
	def self.down
	 execute "DROP FUNCTION IF EXISTS check_days(local_id int, provider_ids int[], serv_ids int[], start_date date, end_date date)"
	end
end
