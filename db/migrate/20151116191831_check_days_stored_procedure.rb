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
	  pt_id int;
	  available_block boolean;
	  response text[][];
	BEGIN

	  IF (select array_length(provider_ids, 1)) != (select array_length(serv_ids, 1)) OR array_length(provider_ids, 1) <= 0 THEN
	    RETURN;
	  END IF;

	  now_date := start_date;

	  <<month_loop>>
	  LOOP
	  	-- RAISE NOTICE 'now_date: %', to_char(now_date, 'YYYY-MM-DD');
	    available_day := FALSE;
	    IF (select provider_ids[1]) = 0 THEN

	    ELSE
	      <<provider_times_loop>>
	      FOR pt_id IN (select id from provider_times where provider_times.service_provider_id = provider_ids[1] AND provider_times.day_id = extract(dow from now_date) ) LOOP
	        now_start := now_date + (select open from provider_times where provider_times.id = pt_id);
	        now_end := now_start + ((select duration from services where services.id = serv_ids[1]) * interval '1 minute');
	        <<day_loop>>
	        LOOP
	          -- RAISE NOTICE 'now_start: %', to_char(now_start, 'YYYY-MM-DD HH24:MI:SS');
	          -- RAISE NOTICE 'now_end: %', to_char(now_end, 'YYYY-MM-DD HH24:MI:SS');
	          available_block := TRUE;
	          IF check_hour(local_id, provider_ids[1], serv_ids[1], now_start, now_end) THEN
	            IF array_length(provider_ids, 1) > 1 THEN
	              now_start_next := now_end;
	              <<providers_loop>>
	              FOR i IN 2 .. ( select array_length(provider_ids, 1)) LOOP
	              	now_end_next := now_start_next + ((select duration from services where services.id = serv_ids[i]) * interval '1 minute');
	                IF NOT check_hour(local_id, provider_ids[i], serv_ids[i], now_start_next, now_end_next) THEN
	                  available_block := FALSE;
	                END IF;
	                now_start_next := now_end_next;
	              END LOOP providers_loop;
	            END IF;
	          ELSE
	          	available_block := FALSE;
	          END IF;
	          now_start := now_start + (5 * interval '1 minute');
	          now_end := now_end + (5 * interval '1 minute');
	          IF available_block THEN
	            available_day := available_block;
	          END IF;
	          EXIT day_loop WHEN available_block = TRUE;
	          EXIT day_loop WHEN now_end > (now_date + (select close from provider_times where provider_times.id = pt_id));
	        END LOOP day_loop;
	      END LOOP provider_times_loop;
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
