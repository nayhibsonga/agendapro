class ProviderOcupationStoredProcedure < ActiveRecord::Migration
  def self.up
   execute <<-__EOI
    CREATE OR REPLACE FUNCTION provider_occupation(provider_id int, start_date date, end_date date)
	returns DECIMAL
	AS 
	$$
	DECLARE
	  now_date date;
	  now_start timestamp;
	  now_end timestamp;
	  pt_id int;
	  cancelled_id int;
	  used_time decimal;
	  available_time decimal;
	BEGIN
	  now_date := start_date;
	  used_time := 0::decimal;
	  available_time := 0::decimal;

	  <<month_loop>>
	  LOOP
	  	-- RAISE NOTICE 'now_date: %', to_char(now_date, 'YYYY-MM-DD');
		<<provider_times_loop>>
		FOR pt_id IN (select id from provider_times where provider_times.service_provider_id = provider_id AND provider_times.day_id = extract(dow from now_date) ) LOOP
		  now_start := now_date + (select open from provider_times where provider_times.id = pt_id);
		  now_end := now_start + (5 * interval '1 minute');
		  <<day_loop>>
		  LOOP
		  	available_time := available_time + 5::decimal;
	    	-- RAISE NOTICE 'now_start: %', to_char(now_start, 'YYYY-MM-DD HH24:MI:SS');
	    	-- RAISE NOTICE 'now_end: %', to_char(now_end, 'YYYY-MM-DD HH24:MI:SS');
	    	cancelled_id := (select id from statuses where name = 'Cancelado');

		  	--Check breaks
		  	IF exists (select id from provider_breaks where provider_breaks.service_provider_id = provider_id AND ((now_start, now_end) OVERLAPS (provider_breaks."start", provider_breaks."end"))) OR exists (select id from bookings where bookings.service_provider_id = provider_id AND bookings.status_id != cancelled_id AND (bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)) AND ((now_start, now_end) OVERLAPS (bookings."start", bookings."end"))) THEN
		    	used_time := used_time + 5::decimal;
		  	END IF;
	      now_start := now_start + time '0:05';
	      now_end := now_end + time '0:05';
		  	EXIT day_loop WHEN now_end > (now_date + (select close from provider_times where provider_times.id = pt_id));
		    END LOOP day_loop;
			END LOOP provider_times_loop;
	    now_date := now_date + 1;
	    EXIT month_loop WHEN now_date > end_date;
	  END LOOP month_loop;
	  RETURN (select used_time / available_time);
	END
	$$ LANGUAGE plpgsql;
   __EOI
 end
 def self.down
   execute "DROP FUNCTION IF EXISTS provider_occupation(provider_id int, start_date date, end_date date)"
 end
end
