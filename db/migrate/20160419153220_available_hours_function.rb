class AvailableHoursFunction < ActiveRecord::Migration
  def self.up
	 execute <<-__EOI

	 	DO $$
		BEGIN
		    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'hour_promo_detail') THEN
		        create type hour_promo_detail as (has_time_discount boolean,time_discount double precision, has_treatment_discount boolean, treatment_discount double precision, service_promo_id int, treatment_promo_id int, price double precision);
		    END IF;
		    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'hour_booking') THEN
		        create type hour_booking as (start_time timestamp, end_time timestamp, provider_id int, provider_name text, price double precision, has_time_discount boolean,time_discount double precision, has_treatment_discount boolean, treatment_discount double precision, service_promo_id int, treatment_promo_id int, dummy_int int);
		    END IF;
		END$$;

		DROP FUNCTION IF EXISTS provider_day_occupation(int, timestamp, timestamp);
		DROP FUNCTION IF EXISTS check_hour(local_id int, provider_id int, serv_id int, start_date timestamp, end_date timestamp);
	 	DROP FUNCTION IF EXISTS check_hour(local_id int, provider_id int, serv_id int, start_date timestamp, end_date timestamp, boolean);
	 	DROP FUNCTION IF EXISTS get_hour_promo_details(timestamp, timestamp, int, int, int, boolean);
	 	DROP FUNCTION IF EXISTS available_hours(int, int, int[], int[], int[], timestamp, timestamp, boolean, int[]);


		CREATE OR REPLACE FUNCTION check_hour(local_id int, provider_id int, serv_id int, start_date timestamp, end_date timestamp, admin boolean)
		returns BOOLEAN
		AS 
		$$
		DECLARE
		  count int;
		  cap int;
		  group boolean;
		  cancelled_id int;
		  resources_used int;
		  resources_count1 int;
		  resources_count2 int;
		  resources_max int;
		  r_id int;
		  current_start timestamp;
		  time_offset double precision;
		BEGIN
		  time_offset := (select countries.timezone_offset from countries where id = (select companies.country_id from companies where id = (select locations.company_id from locations where id = local_id)));
  		  current_start := localtimestamp + interval '1hr' * time_offset;
		  cancelled_id := (select id from statuses where name = 'Cancelado');

		  --Check location_times
		  IF not exists(select id from location_times where location_times.location_id = local_id AND location_times.day_id = extract(dow from start_date) AND location_times.open <= (select "time"(start_date)) AND location_times.close >= (select "time"(end_date))) THEN
		  	return false;
		  	END IF;

		  --Check after and before settings if not admin
		  IF (admin = false) THEN
			  IF start_date < current_start + ((select before_booking from company_settings where company_settings.company_id = (select company_id from locations where locations.id = local_id)) * interval '1 hour') OR end_date > current_start + ((select after_booking from company_settings where company_settings.company_id = (select company_id from locations where locations.id = local_id)) * interval '1 month') THEN
			  	return false;
			  END IF;
		  ELSE
		  	IF start_date < current_start THEN
			  	return false;
			END IF;
		  END IF;

		  --Check provider_times
		  IF not exists (select id from provider_times where provider_times.service_provider_id = provider_id AND provider_times.day_id = extract(dow from start_date) AND provider_times.open <= (select "time"(start_date)) AND provider_times.close >= (select "time"(end_date))) THEN
		    return false;
		  END IF;

		  --Check service_times
		  IF (select time_restricted from services where services.id = serv_id limit 1) THEN
		  	IF not exists(select id from service_times where service_times.service_id = serv_id AND service_times.day_id = extract(dow from start_date) AND service_times.open <= (select "time"(start_date)) AND service_times.close >= (select "time"(end_date)))  THEN
		  		return false;
		  	END IF;
		  END IF;

		  --Check breaks
		  IF exists (select id from provider_breaks where provider_breaks.service_provider_id = provider_id AND ((start_date, end_date) OVERLAPS (provider_breaks."start", provider_breaks."end"))) THEN
		    return false;
		  END IF;

		  --Check cross bookings
		IF exists (select id from bookings where bookings.service_provider_id = provider_id AND bookings.service_id <> serv_id AND bookings.status_id != 5 AND (bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)) AND ((start_date, end_date) OVERLAPS (bookings."start", bookings."end"))) THEN
		  return false;
		END IF;
		  IF (select group_service from services where id = serv_id) = false THEN
		  	IF exists (select id from bookings where bookings.service_provider_id = provider_id AND bookings.status_id != 5 AND (bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)) AND ((start_date, end_date) OVERLAPS (bookings."start", bookings."end"))) THEN
		  return false;
		END IF;
		  ELSE
		    count := (select count(id) from bookings where bookings.service_provider_id = provider_id AND bookings.status_id != 5 AND (bookings.is_session = false or (bookings.is_session = true AND bookings.is_session_booked = true)) AND ((start_date, end_date) OVERLAPS (bookings."start", bookings."end")));
		    cap := (select capacity from services where id = serv_id);
		    IF count >= cap THEN
		        return false;
		    END IF;
		  END IF;

		  --Check resources
		  IF exists(select resource_id from service_resources where service_resources.service_id = serv_id) THEN

		    -- Loop through all service's resources
		    FOR r_id IN (select resource_id from service_resources where service_resources.service_id = serv_id) LOOP

		      IF NOT exists(select resource_id from resource_locations where resource_locations.resource_id = r_id AND resource_locations.location_id = local_id) THEN
		        return false;
		      END IF;
		      -- Get resources quantity
		      resources_max := (select quantity from resource_locations where resource_locations.resource_id = r_id AND resource_locations.location_id = local_id);

		      -- Get used resources from not group service location bookings
		      resources_count1 := ( select count(id) from bookings where bookings.service_id in (select id from services where group_service = false) AND bookings.location_id = local_id AND bookings.status_id != 5 AND (bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)) AND ((start_date, end_date) OVERLAPS (bookings."start", bookings."end")) AND bookings.service_id in (select serv_id from service_resources where service_resources.resource_id = r_id) );
		      -- Get used resources from group service location bookings
		      resources_count2 := ( select count(*) from ( select DISTINCT(service_provider_id) from bookings where bookings.service_id in (select id from services where group_service = true) AND (bookings.service_id != serv_id OR bookings.service_provider_id != provider_id) AND bookings.location_id = local_id AND bookings.status_id != 5 AND (bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)) AND ((start_date, end_date) OVERLAPS (bookings."start", bookings."end")) AND bookings.service_id in (select serv_id from service_resources where service_resources.resource_id = r_id) ) as rc_query );

		      IF resources_max <= resources_count1 + resources_count2 THEN
		        return FALSE;
		      END IF;

		    END LOOP;

		  END IF;
		 
		  return true;

		END
		$$ LANGUAGE plpgsql;


		CREATE OR REPLACE FUNCTION provider_day_occupation(provider_id int, start_date timestamp, end_date timestamp)
		returns DECIMAL
		AS 
		$$
		DECLARE
		  start_time time;
		  end_time time;
		  used_time time;
		  available_time time;
		  break_time time;
		  partial_start_break_time time;
		  partial_end_break_time time;
		  used_epoch decimal;
		  available_epoch decimal;
		  break_epoch decimal;
		  start_break_epoch decimal;
		  end_break_epoch decimal;
		  available_sum decimal;
		  day int;
		BEGIN

		  --used_time := 0::decimal;
		  --available_time := 0::decimal;
		  day := extract(dow from start_date);

		  used_epoch := 0;
		  available_epoch := 0;
		  break_epoch := 0;
		  start_break_epoch := 0;
		  end_break_epoch := 0;
		  available_sum := 0;

		  select into used_time SUM(bookings."end" - bookings."start") from bookings where bookings."start" >= start_date AND bookings."end" <= end_date AND bookings.service_provider_id = provider_id;
		  select into available_time SUM(provider_times.close - provider_times.open) from provider_times where provider_times.day_id = day and provider_times.service_provider_id = provider_id;
		  select into break_time SUM(provider_breaks."end" - provider_breaks."start") from provider_breaks where provider_breaks."start" >= start_date and provider_breaks."end" <= end_date and provider_breaks.service_provider_id = provider_id;
		  select into partial_start_break_time SUM(provider_breaks."end" - start_date) from provider_breaks where provider_breaks."start" < start_date and provider_breaks."end" <= end_date and provider_breaks."end" > start_date and provider_breaks.service_provider_id = provider_id;
		  select into partial_end_break_time SUM(end_date - provider_breaks."start") from provider_breaks where provider_breaks."start" >= start_date and provider_breaks."end" > end_date and provider_breaks."start" < end_date and provider_breaks.service_provider_id = provider_id;

		  IF used_time IS NOT NULL THEN
		    used_epoch := (select extract(epoch from used_time));
		  END IF;

		  IF available_time IS NOT NULL THEN
		    available_epoch := (select extract(epoch from available_time));
		  END IF;

		  IF break_time IS NOT NULL THEN
		    break_epoch := (select extract(epoch from break_time));
		  END IF;

		  IF partial_start_break_time IS NOT NULL THEN
		    start_break_epoch := (select extract(epoch from partial_start_break_time));
		  END IF;

		  IF partial_end_break_time IS NOT NULL THEN
		    end_break_epoch := (select extract(epoch from partial_end_break_time));
		  END IF;

		  available_sum := available_epoch - break_epoch - start_break_epoch - end_break_epoch;

		  IF available_sum = 0 THEN
		    RETURN 0::decimal;
		  ELSE
		    RETURN (used_epoch / available_sum);
		  END IF;
		END
		$$ LANGUAGE plpgsql;


		CREATE OR REPLACE FUNCTION get_hour_promo_details(start_time timestamp, end_time timestamp, service_id int, local_id int, day int, bundle_present boolean)
		returns hour_promo_detail
		AS
		$$
		DECLARE
		  result_record hour_promo_detail;
		  service services%ROWTYPE;
		  company_setting company_settings%ROWTYPE;
		  location locations%ROWTYPE;
		  service_promo service_promos%ROWTYPE;
		  treatment_promo treatment_promos%ROWTYPE;
		  promo promos%ROWTYPE;
		  now timestamp;
		  ret record;

		  has_time_discount boolean;
		  time_discount double precision;
		  has_treatment_discount boolean;
		  treatment_discount double precision;
		  service_promo_id int;
		  treatment_promo_id int;
		  price double precision;
		  promo_id int;
		  --(has_discount boolean, has_time_discount boolean, discount float, time_discount float, has_treatment_discount boolean, treatment_discount_discount float);
		BEGIN

		  --service := (select * from services where id = service_id limit 1);
		  SELECT INTO service * from services where id = service_id;
		  --company_setting := (select * from company_settings where company_id = service.company_id limit 1);
		  --location := (select * from locations where id = local_id limit 1);
		  SELECT INTO company_setting * from company_settings where company_id = service.company_id limit 1;
		  SELECT INTO location * from locations where id = local_id;

		  --RAISE NOTICE 'SERVICE: %', service;

		  now := localtimestamp;

		  has_time_discount := FALSE;
		  time_discount := 0;
		  has_treatment_discount := FALSE;
		  treatment_discount := 0;

		  IF service.online_payable = FALSE OR company_setting.online_payment_capable = FALSE OR bundle_present THEN

		    has_time_discount := FALSE;
		    time_discount := 0;
		    has_treatment_discount := FALSE;
		    treatment_discount := 0;

		  ELSE

		    IF company_setting.promo_offerer_capable = FALSE THEN

		      has_time_discount := FALSE;
		      time_discount := 0;
		      has_treatment_discount := FALSE;
		      treatment_discount := 0;

		    END IF;

		    IF service.has_sessions = FALSE THEN

		      has_treatment_discount := FALSE;
		      treatment_discount := 0;

		      IF (service.has_time_discount AND company_setting.promo_offerer_capable AND service.time_promo_active) THEN

		        IF exists(select id from promos where day_id = day and promos.service_promo_id = service.active_service_promo_id and location_id = local_id) THEN
		          --service_promo := (select * from service_promos where id = service.active_service_promo_id);
		          SELECT INTO service_promo * from service_promos where id = service.active_service_promo_id;
		          SELECT INTO promo * from promos where day_id = day and promos.service_promo_id = service.active_service_promo_id and location_id = local_id;
		          --Check for stock or limit
		          IF ((service_promo.max_bookings > 0) OR (service_promo.limit_booking)) = FALSE THEN

		            --Check if promo is still active and if end_time is before limit date.
		            IF ((end_time < service_promo.book_limit_date) AND (now < service_promo.finish_date)) THEN

		              IF ( to_char(service_promo.morning_start, 'HH24:MI') >= to_char(end_time, 'HH24:MI') OR to_char(service_promo.morning_end, 'HH24:MI') <= to_char(start_time, 'HH24:MI') ) = FALSE THEN
		                time_discount := promo.morning_discount;
		              ELSIF ( to_char(service_promo.afternoon_start, 'HH24:MI') >= to_char(end_time, 'HH24:MI') OR to_char(service_promo.afternoon_end, 'HH24:MI') <= to_char(start_time, 'HH24:MI') ) = FALSE THEN
		                time_discount := promo.afternoon_discount;
		              ELSIF ( to_char(service_promo.night_start, 'HH24:MI') >= to_char(end_time, 'HH24:MI') OR to_char(service_promo.night_end, 'HH24:MI') <= to_char(start_time, 'HH24:MI') ) = FALSE THEN
		                time_discount := promo.night_discount;
		              ELSE
		                time_discount := 0;
		              END IF;

		            END IF;

		          END IF;


		        END IF;

		      END IF;

		      --RAISE NOTICE 'TIME DISCOUNT: %', time_discount;

		      IF time_discount > 0 THEN
		        has_time_discount := TRUE;
		      END IF;

		      --RAISE NOTICE 'HAS TIME DISCOUNT: %', has_time_discount;

		    ELSE

		      has_time_discount := FALSE;
		      time_discount := 0;

		      IF (service.has_treatment_promo AND company_setting.promo_offerer_capable AND service.time_promo_active) THEN

		        IF exists(select id from treatment_promos where service_id = service.id) && exists(select id from treatment_promo_locations where location_id = local_id and treatment_promo_id = service.active_treatment_promo_id) THEN

		          --treatment_promo := (select * from treatment_promos where id = service.active_treatment_promo_id);
		          SELECT INTO treatment_promo * from treatment_promos where id = service.active_treatment_promo_id;

		          IF ((treatment_promo.max_bookings > 0) AND ((treatment_promo.limit_booking = FALSE OR (treatment_promo.finish_date > start_time) ))) THEN

		            has_treatment_discount := TRUE;
		            treatment_discount := treatment_promo.discount;

		          END IF;

		        END IF;

		      END IF;

		    END IF;

		    IF service.active_service_promo_id IS NULL THEN
		      service_promo_id = 0;
		    ELSE
		      service_promo_id = service.active_service_promo_id;
		    END IF;

		    IF service.active_treatment_promo_id IS NULL THEN
		      treatment_promo_id = 0;
		    ELSE
		      treatment_promo_id = service.active_treatment_promo_id;
		    END IF;

		  END IF;

		  result_record.has_time_discount := has_time_discount;
		  result_record.time_discount := time_discount;
		  result_record.has_treatment_discount := has_treatment_discount;
		  result_record.treatment_discount := treatment_discount;
		  result_record.service_promo_id := service_promo_id;
		  result_record.treatment_promo_id := treatment_promo_id;
		  result_record.price := service.price;

		  RETURN result_record;

		  --price := service.price;

		  --SELECT has_time_discount, time_discount, has_treatment_discount, treatment_discount, service_promo_id, treatment_promo_id, price INTO ret;

		  --RETURN ret;

		END
		$$ LANGUAGE plpgsql;



	 	CREATE OR REPLACE FUNCTION available_hours(company_id int, local_id int, providers_ids int[], service_ids int[], bundle_ids int[], start_date timestamp, end_date timestamp, admin boolean, first_providers_ids int[])
		returns TABLE(hour_array hour_booking[], positive_gap int)--hour_booking[][]
		AS
		$$
		DECLARE

		  day int;
		  comp_id int;
		  dtp timestamp;
		  day_open_time timestamp;
		  service_staff_pos int;
		  service_staff_length int;
		  hours_array hour_booking[][];
		  hour_bookings hour_booking[];
		  hour_booking hour_booking;
		  promo_detail hour_promo_detail;
		  service_valid boolean;
		  service_id int;
		  provider_id int;
		  bundle_id int;
		  bundle_present boolean;
		  current_service_providers int[];
		  min_open time;
		  min_calc timestamp;
		  min_aux timestamp;
		  allows_optimization boolean;
		  allows_overlap boolean;
		  duration int;
		  first_duration int;
		  leap int;
		  min_hour timestamp;
		  before_time timestamp;
		  after_time timestamp;
		  durations int[];
		  current_service_providers_ids int[];
		  elegible_ids int;
		  elegible_ids_count int;
		  selected_provider_id int;

		  po_start_date date;
		  po_end_date date;

		  --Optimized search vars
		  positive_gaps int;
		  max_time_diff int;
		  loop_times int;
		  last_check boolean;
		  is_gap_hour boolean;
		  current_gap int;
		  time_gap int;

		  offset_diff int;
		  offset_rem int;

		  book_gap timestamp;
		  break_gap timestamp;
		  time_provider_time_gap time;
		  provider_time_gap timestamp;
		  time_provider_close time;
		  provider_close timestamp;
		  gap_diff int;

		  smallest_diff int;
		  book_diff int;
		  break_diff int;

		  book_blocking timestamp;
		  break_blocking timestamp;


		  --Params for each booking row

		BEGIN

		  day := extract(dow from start_date);
		  comp_id := company_id;
		  before_time := localtimestamp + ((select before_booking from company_settings where company_settings.company_id = comp_id) * interval '1 hour');
		  after_time := localtimestamp + ((select after_booking from company_settings where company_settings.company_id = comp_id) * interval '1 month');

		  po_start_date := date_trunc('day', start_date);
		  po_end_date := date_trunc('day', end_date);

		  dtp := start_date;
		  day_open_time = dtp;
		  service_staff_length := array_length(service_ids, 1);
		  duration := (select sum(services.duration) from services where id = ANY(service_ids));
		  first_duration := (select services.duration from services where id = service_ids[1]);

		  --Optimized search definitions
		  allows_optimization := (select company_settings.allows_optimization from company_settings where company_settings.company_id = comp_id);
		  allows_overlap := (select company_settings.allows_overlap_hours from company_settings where company_settings.company_id = comp_id);
		  positive_gaps := 0;
		  max_time_diff := 0;
		  loop_times := 0;
		  last_check := false;
		  is_gap_hour := false;
		  current_gap := 0;
		  --hours_array := ARRAY[]::hour_booking[];


		  --Calculate leap
		  IF array_length(providers_ids, 1) > 1 THEN
		    leap := (select booking_leap from company_settings where company_settings.company_id = comp_id limit 1);
		  ELSE
		    IF array_length(providers_ids, 1) > 0 THEN
		      IF providers_ids[1] = 0 THEN
		        leap := (select booking_leap from company_settings where company_settings.company_id = comp_id limit 1);
		      ELSE
		        leap := (select booking_leap from service_providers where id = providers_ids[1] limit 1);
		      END IF;
		    ELSE
		      RAISE EXCEPTION 'No providers given.'
		      USING HINT = 'Please check your providers options.';
		    END IF;
		  END IF;

		  --Get durations
		  <<durations_loop>>
		  FOR i IN 1 .. ( select array_length(service_ids, 1)) LOOP
		    durations[i] := (select services.duration from services where id = service_ids[i]);
		  END LOOP durations_loop;

		  --Check presence of provider_times and location_time

		  IF not exists(select id from location_times where location_times.location_id = local_id AND location_times.day_id = day) THEN
		    -- No location_time, return from function;
		    RETURN;
		  END IF;

		  --Check for providers_times
		  --IF not exists()

		 --RAISE NOTICE 'LEAP: %', leap;

		  <<day_loop>>
		  LOOP
		    service_staff_pos := 1;
		    hour_bookings := ARRAY[]::hour_booking[];
		    <<staff_loop>>
		      LOOP
		      service_valid := false;
		      service_id := service_ids[service_staff_pos];
		      bundle_id := bundle_ids[service_staff_pos];
		      bundle_present := FALSE;

		      IF bundle_id > 0 THEN
		        bundle_present := TRUE;
		      END IF;

		      current_service_providers_ids := (select array(select id from service_providers as t1 where active = true and online_booking = true and location_id = local_id and id in (select service_provider_id from service_staffs as t2 where t1.id = t2.service_provider_id)));

		      --Break if there are no providers
		      IF array_length(current_service_providers_ids, 1) < 1 THEN
		        RETURN;
		        EXIT staff_loop;
		      END IF;

		      --Get providers min open
		      min_open := (select open from provider_times where service_provider_id = ANY(current_service_providers_ids) and day_id = day order by open limit 1);

		      IF EXISTS(select open from provider_times where service_provider_id = ANY(current_service_providers_ids) and day_id = day order by open limit 1) THEN
		        --Nothing
		      ELSE
		        RETURN;
		        EXIT staff_loop;
		      END IF;

		      min_aux := (select date_trunc('day', dtp));
		      min_calc := (select min_aux + interval '1h' * date_part('hour', min_open) + interval '1' minute * date_part('minute', min_open));

		      IF min_calc > dtp THEN
		        dtp := min_calc; -- check how to assign time
		      END IF;

		      --This is to overlaps hours when not optimized
		     --RAISE NOTICE 'BEFORE STATE: service_staff_pos: % - allows_optimization: % - last_check % - allows_overlap %', service_staff_pos, allows_optimization, last_check, allows_overlap;
		      IF ((service_staff_pos = 1) AND (allows_optimization = false) AND (last_check = true) AND (allows_overlap = TRUE)) THEN
		       --RAISE NOTICE 'ENTERS WITH % - DURATION IS % - LEAP IS %', dtp, duration, leap;
		        dtp := (select dtp - interval '1' minute * duration + interval '1' minute * leap);
		       --RAISE NOTICE 'LEAVES WITH %', dtp;
		      END IF;

		      --This is for calculating jump when there is no optimization
		      IF ((service_staff_pos = 1) AND (allows_optimization = false)) THEN
		        offset_diff := (select (date_part('minute', dtp) - date_part('minute', day_open_time)));
		        offset_rem := offset_diff % leap;
		        IF offset_rem != 0 THEN
		          dtp:= dtp + interval '1' minute * (leap - offset_rem);
		        END IF;
		      END IF;

		      IF dtp >= before_time THEN
		        service_valid := true;
		      END IF;


		      IF providers_ids[service_staff_pos] != 0 THEN

		       --RAISE NOTICE 'CHECKING FOR % - %', dtp, dtp + interval '1' minute * durations[service_staff_pos];

		        service_valid := check_hour(local_id, providers_ids[service_staff_pos], service_ids[service_staff_pos], dtp, dtp + interval '1' minute * durations[service_staff_pos], admin);

		        selected_provider_id := providers_ids[service_staff_pos];

		      ELSE
		        select into elegible_ids id from (select id, provider_day_occupation(id, start_date, end_date) from service_providers where check_hour(local_id, service_providers.id, service_ids[service_staff_pos], dtp, dtp + interval '1' minute * durations[service_staff_pos], admin) = TRUE AND active = true AND online_booking = true AND id IN (select service_staffs.service_provider_id from service_staffs where service_staffs.service_id = service_ids[service_staff_pos]) AND id IN (select provider_times.service_provider_id from provider_times where day_id = day) ORDER BY provider_day_occupation(id, start_date, end_date)) AS elegible_providers limit 1;
		        GET DIAGNOSTICS elegible_ids_count = ROW_COUNT;
		        --RAISE NOTICE 'Elegible ids: % - Count: %', elegible_ids, elegible_ids_count;
		        --RAISE NOTICE 'ELEGIBLE IDS: %', elegible_ids;
		        IF elegible_ids_count > 0 THEN
		          selected_provider_id := elegible_ids;
		          service_valid := TRUE;

		        ELSE
		          service_valid := FALSE;
		        END IF;
		      END IF;

		      service_staff_pos := service_staff_pos + 1;

		      IF service_valid THEN

		        -- asign booking
		        hour_booking.start_time := dtp;
		        hour_booking.end_time := dtp + interval '1' minute * durations[service_staff_pos-1];
		        --Set provider_id and lock
		        hour_booking.provider_id := selected_provider_id;
		        hour_booking.provider_name := (select public_name from service_providers where id = selected_provider_id);
		        promo_detail := (select get_hour_promo_details(hour_booking.start_time, hour_booking.end_time, service_ids[service_staff_pos-1], local_id, day, bundle_present));

		        hour_booking.has_time_discount := promo_detail.has_time_discount;
		        --RAISE NOTICE 'Promo detail has_time_discount and time_discount: % - %', promo_detail.has_time_discount, promo_detail.time_discount;
		        hour_booking.time_discount := promo_detail.time_discount;
		        hour_booking.has_treatment_discount := promo_detail.has_treatment_discount;
		        hour_booking.treatment_discount := promo_detail.treatment_discount;
		        hour_booking.service_promo_id := promo_detail.service_promo_id;
		        hour_booking.treatment_promo_id := promo_detail.treatment_promo_id;
		        hour_booking.price := promo_detail.price;
		        hour_booking.dummy_int := 1;

		        --RAISE NOTICE 'Promo detail: %', string_agg(promo_detail, ',');

		        --RAISE NOTICE 'HOUR VALID: % - %', hour_booking.start_time, hour_booking.end_time;

		        --hour_bookings := array_append(hour_bookings, hour_booking);
		        hour_bookings[service_staff_pos-1] := hour_booking;

		        IF allows_optimization THEN
		          IF min_calc > dtp THEN
		            dtp := min_calc;
		          ELSE
		          dtp := dtp + interval '1' minute * durations[service_staff_pos-1];
		          END IF;
		        ELSE
		          dtp := dtp + interval '1' minute * durations[service_staff_pos-1];
		        END IF;
		        --CHECK THIS
		        IF service_staff_pos = array_length(service_ids, 1) + 1 THEN
		          last_check := true;
		          IF is_gap_hour THEN
		            positive_gaps := positive_gaps + duration - current_gap;
		            is_gap_hour := false;
		            current_gap := 0;
		          ELSE
		            IF allows_overlap AND (allows_optimization = FALSE) THEN
		              positive_gaps := positive_gaps + duration - leap;
		            END IF;
		          END IF;
		        END IF;

		      ELSE

		        --RAISE NOTICE 'HOUR NOT VALID: % - %', dtp, dtp + interval '1' minute * durations[service_staff_pos-1];

		        hour_bookings := ARRAY[]::hour_booking[];
		        --Reset gap_hour
		        is_gap_hour := false;

		        --First, check if there's a gap. If so, back dateTimePointer to (blocking_start - total_duration)
		        --This way, you can give two options when there are gaps.

		        --Assume there is no gap
		        time_gap := 0;

		        IF (allows_optimization AND last_check) THEN



		          --Look for gaps, that is bookings
		          --that could overlap current time window
		          --to see if anything fits before next
		          --booking, break or time close

		          --IMPORTANT
		          --When they are times, add date

		          book_gap := (select bookings.start from bookings where service_provider_id = ANY(first_providers_ids) and bookings.end >= dtp and bookings.start <= (dtp + interval '1' minute * first_duration) order by bookings.start limit 1);

		          break_gap := (select provider_breaks.start from provider_breaks where service_provider_id = ANY(first_providers_ids) and provider_breaks.end >= dtp and provider_breaks.start <= (dtp + interval '1' minute * first_duration) order by provider_breaks.start limit 1);

		          time_provider_time_gap := (select provider_times.close from provider_times where service_provider_id = ANY(first_providers_ids) and day_id = day order by provider_times.close limit 1);

		          provider_time_gap := (select date_trunc('day', dtp) + interval '1h' * date_part('hour', time_provider_time_gap) + interval '1' minute * date_part('minute', time_provider_time_gap));

		          -- Check if there is a provider close

		          IF exists(select provider_times.close from provider_times where service_provider_id = ANY(first_providers_ids) and day_id = day order by provider_times.close limit 1) THEN

		            provider_close := date_trunc('day', dtp) + interval '1h' * date_part('hour', provider_time_gap) + interval '1' minute * date_part('minute', provider_time_gap);

		            --Check if provider_close is between current time window. If so, assign time_gap.

		            IF (dtp < provider_close) AND (provider_close < (dtp + interval '1' minute * duration)) THEN

		              gap_diff := (select extract( epoch from (provider_close - dtp) ) / 60);

		              IF gap_diff > time_gap THEN
		                time_gap := gap_diff;
		              END IF;

		            END IF;

		          END IF;

		          IF exists(select bookings.start from bookings where service_provider_id = ANY(first_providers_ids) and bookings.end >= dtp and bookings.start <= (dtp + interval '1' minute * first_duration) order by bookings.start limit 1) THEN
		            gap_diff := (select extract( epoch from (book_gap - dtp) ) / 60);
		            IF gap_diff > time_gap THEN
		                time_gap := gap_diff;
		              END IF;
		          END IF;

		          IF exists(select provider_breaks.start from provider_breaks where service_provider_id = ANY(first_providers_ids) and provider_breaks.end >= dtp and provider_breaks.start <= (dtp + interval '1' minute * first_duration) order by provider_breaks.start limit 1) THEN
		            gap_diff := (select extract( epoch from (break_gap - dtp) ) / 60);
		            IF gap_diff > time_gap THEN
		                time_gap := gap_diff;
		              END IF;
		          END IF;

		        END IF;

		        smallest_diff := first_duration;
		        book_diff := smallest_diff;
		        break_diff := smallest_diff;

		        --When there is no gap, calculate smalles_diff.
		        IF ((allows_optimization) AND (time_gap = 0)) THEN

		          book_blocking := (select bookings.end from bookings where service_provider_id = ANY(first_providers_ids) and bookings.end >= dtp and bookings.start <= (dtp + interval '1' minute * first_duration) order by bookings.end limit 1);

		          IF exists(select bookings.end from bookings where service_provider_id = ANY(first_providers_ids) and bookings.end >= dtp and bookings.start <= (dtp + interval '1' minute * first_duration) order by bookings.end limit 1) THEN

		            book_diff := (select (extract (epoch from (book_blocking - dtp) ) ) / 60);
		            IF book_diff < smallest_diff THEN
		              smallest_diff := book_diff;
		            END IF;

		          ELSE

		            break_blocking := (select provider_breaks.end from provider_breaks where service_provider_id = ANY(first_providers_ids) and provider_breaks.end >= dtp and provider_breaks.start <= (dtp + interval '1' minute * first_duration) order by provider_breaks.end limit 1);

		              IF exists(select provider_breaks.end from provider_breaks where service_provider_id = ANY(first_providers_ids) and provider_breaks.end >= dtp and provider_breaks.start <= (dtp + interval '1' minute * first_duration) order by provider_breaks.end limit 1) THEN

		                break_diff := (select (extract (epoch from (break_blocking - dtp) ) ) / 60);

		                IF break_diff < smallest_diff THEN
		                  smallest_diff := break_diff;
		                END IF;

		              END IF;

		          END IF;

		          IF smallest_diff = 0 THEN
		            smallest_diff := first_duration;
		          END IF;

		        ELSE

		          smallest_diff := leap;

		        END IF;

		        IF (allows_optimization AND (time_gap > 0)) THEN
		          dtp := (dtp + interval '1' minute * time_gap) - interval '1' minute * duration;
		          is_gap_hour := TRUE;
		          current_gap := time_gap;
		        ELSE
		          current_gap := 0;
		          dtp := (dtp + interval '1' minute * smallest_diff);
		        END IF;

		        service_staff_pos := 1;
		        last_check := false;

		      END IF;

		      EXIT staff_loop WHEN ((service_staff_pos > service_staff_length) OR (dtp >= end_date));
		    END LOOP staff_loop;

		    --Add hour_bookings to hours_array if length is equal to service_staff_length
		    IF array_length(hour_bookings, 1) = service_staff_length THEN

		      hour_array := hour_bookings;--array_append(hours_array, hour_bookings);
		      positive_gap := positive_gaps;
		      RETURN NEXT;
		    ELSE

		    END IF;

		    EXIT day_loop WHEN dtp >= end_date;
		  END LOOP day_loop;

		  --return hours_array;

		END
		$$ LANGUAGE plpgsql;


	  __EOI
	end
	def self.down
	 execute "DROP TYPE IF EXISTS hour_promo_detail CASCADE"
	 execute "DROP TYPE IF EXISTS hour_booking CASCADE"
	 execute "DROP FUNCTION IF EXISTS provider_day_occupation(int, timestamp, timestamp)"
	 execute "DROP FUNCTION IF EXISTS check_hour(local_id int, provider_id int, serv_id int, start_date timestamp, end_date timestamp)"
	 execute "DROP FUNCTION IF EXISTS get_hour_promo_details(timestamp, timestamp, int, int, int, boolean)"
	 execute "DROP FUNCTION IF EXISTS available_hours(int, int, int[], int[], int[], timestamp, timestamp, boolean, int[])"
	end
end
