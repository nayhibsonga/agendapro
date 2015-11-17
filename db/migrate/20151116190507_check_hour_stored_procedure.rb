class CheckHourStoredProcedure < ActiveRecord::Migration
  def self.up
   execute <<-__EOI
	CREATE OR REPLACE FUNCTION check_hour(local_id int, provider_id int, serv_id int, start_date timestamp, end_date timestamp)
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
	  BEGIN

	    cancelled_id := (select id from statuses where name = 'Cancelado');

	    --Check breaks
	    IF exists (select id from provider_breaks where provider_breaks.service_provider_id = provider_id AND not(provider_breaks."end" <= start_date OR end_date <= provider_breaks."start")) THEN
	      return false;
	    END IF;

	    --Check cross bookings
	    IF (select group_service from services where id = serv_id) = false THEN
	      IF exists (select id from bookings where bookings.service_provider_id = provider_id AND bookings.status_id != 5 AND (bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)) AND not(bookings."end" <= start_date OR end_date <= bookings."start")) THEN
	        return false;
	      END IF;
	    ELSE
	      count := (select count(id) from bookings where bookings.service_provider_id = provider_id AND bookings.status_id != 5 AND (bookings.is_session = false or (bookings.is_session = true AND bookings.is_session_booked = true)) AND not(bookings."end" <= start_date OR end_date <= bookings."start"));
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
	        resources_count1 := ( select count(id) from bookings where bookings.service_id in (select id from services where group_service = false) AND bookings.location_id = local_id AND bookings.status_id != 5 AND (bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)) AND not(bookings."end" <= start_date OR end_date <= bookings."start") AND bookings.service_id in (select serv_id from service_resources where service_resources.resource_id = r_id) );
	        -- Get used resources from group service location bookings
	        resources_count2 := ( select count(*) from ( select DISTINCT(service_provider_id) from bookings where bookings.service_id in (select id from services where group_service = true) AND (bookings.service_id != serv_id OR bookings.service_provider_id != provider_id) AND bookings.location_id = local_id AND bookings.status_id != 5 AND (bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)) AND not(bookings."end" <= start_date OR end_date <= bookings."start") AND bookings.service_id in (select serv_id from service_resources where service_resources.resource_id = r_id) ) as rc_query );

	        IF resources_max <= resources_count1 + resources_count2 THEN
	          return FALSE;
	        END IF;

	      END LOOP;

	    END IF;
	   
	    return true;

	  END
	$$ LANGUAGE plpgsql;
   __EOI
 end
 def self.down
   execute "DROP FUNCTION IF EXISTS check_hour(local_id int, provider_id int, serv_id int, start_date timestamp, end_date timestamp)"
 end
end
