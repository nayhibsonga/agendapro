class CreateLocationsSearchFunction < ActiveRecord::Migration

  	def self.up
	  	execute <<-__EOI
	  		CREATE OR REPLACE FUNCTION locations_search(searchInput varchar, latitudeInput double precision, longitudeInput double precision)
			returns TABLE(location_id integer)
			AS 
			$$
			DECLARE

				owned_count int;
				unowned_count int;

				owned_index int;
				unowned_index int;

			  	owned_location locations%rowtype;
			  	unowned_location locations%rowtype;

			BEGIN

				--Get owned companies first
				DROP TABLE IF EXISTS owned_locations;

				CREATE TEMP TABLE owned_locations AS SELECT "locations".*, ((ts_rank((to_tsvector('simple', unaccent(coalesce(pg_search_1.pg_search_2::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_1.pg_search_3::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_4.pg_search_5::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_6.pg_search_7::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_8.pg_search_9::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_10.pg_search_11::text, '')))), (to_tsquery('simple', ''' ' || unaccent(searchInput) || ' ''' || ':*')), 0))) AS pg_search_rank FROM "locations" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("companies"."name"::text, ' ') AS pg_search_2, string_agg("companies"."web_address"::text, ' ') AS pg_search_3 FROM "locations" INNER JOIN "companies" ON "companies"."id" = "locations"."company_id" GROUP BY "locations"."id") pg_search_1 ON pg_search_1.id = "locations"."id" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("economic_sectors"."name"::text, ' ') AS pg_search_5 FROM "locations" INNER JOIN "companies" ON "companies"."id" = "locations"."company_id" INNER JOIN "company_economic_sectors" ON "company_economic_sectors"."company_id" = "companies"."id" INNER JOIN "economic_sectors" ON "economic_sectors"."id" = "company_economic_sectors"."economic_sector_id" GROUP BY "locations"."id") pg_search_4 ON pg_search_4.id = "locations"."id" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("economic_sectors_dictionaries"."name"::text, ' ') AS pg_search_7 FROM "locations" INNER JOIN "companies" ON "companies"."id" = "locations"."company_id" INNER JOIN "company_economic_sectors" ON "company_economic_sectors"."company_id" = "companies"."id" INNER JOIN "economic_sectors" ON "economic_sectors"."id" = "company_economic_sectors"."economic_sector_id" INNER JOIN "economic_sectors_dictionaries" ON "economic_sectors_dictionaries"."economic_sector_id" = "economic_sectors"."id" GROUP BY "locations"."id") pg_search_6 ON pg_search_6.id = "locations"."id" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("service_categories"."name"::text, ' ') AS pg_search_9 FROM "locations" INNER JOIN "service_providers" ON "service_providers"."location_id" = "locations"."id" AND "service_providers"."active" = 't' INNER JOIN "service_staffs" ON "service_staffs"."service_provider_id" = "service_providers"."id" INNER JOIN "services" ON "services"."id" = "service_staffs"."service_id" AND "services"."active" = 't' AND "services"."online_booking" = 't' INNER JOIN "service_categories" ON "service_categories"."id" = "services"."service_category_id" GROUP BY "locations"."id") pg_search_8 ON pg_search_8.id = "locations"."id" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("services"."name"::text, ' ') AS pg_search_11 FROM "locations" INNER JOIN "service_providers" ON "service_providers"."location_id" = "locations"."id" AND "service_providers"."active" = 't' INNER JOIN "service_staffs" ON "service_staffs"."service_provider_id" = "service_providers"."id" INNER JOIN "services" ON "services"."id" = "service_staffs"."service_id" AND "services"."active" = 't' AND "services"."online_booking" = 't' GROUP BY "locations"."id") pg_search_10 ON pg_search_10.id = "locations"."id" WHERE ((similarity((unaccent(coalesce(pg_search_1.pg_search_2::text, '') || ' ' || coalesce(pg_search_1.pg_search_3::text, '') || ' ' || coalesce(pg_search_4.pg_search_5::text, '') || ' ' || coalesce(pg_search_6.pg_search_7::text, '') || ' ' || coalesce(pg_search_8.pg_search_9::text, '') || ' ' || coalesce(pg_search_10.pg_search_11::text, ''))), unaccent(searchInput)) >= 0.1) OR ((to_tsvector('simple', unaccent(coalesce(pg_search_1.pg_search_2::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_1.pg_search_3::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_4.pg_search_5::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_6.pg_search_7::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_8.pg_search_9::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_10.pg_search_11::text, '')))) @@ (to_tsquery('simple', ''' ' || unaccent(searchInput) || ' ''' || ':*')))) AND "locations"."online_booking" = 't' AND "locations"."id" IN (SELECT "service_providers"."location_id" FROM "service_providers" WHERE "service_providers"."active" = 't' AND "service_providers"."online_booking" = 't' AND "service_providers"."id" IN (SELECT "service_staffs"."service_provider_id" FROM "service_staffs" WHERE "service_staffs"."service_id" IN (SELECT "services"."id" FROM "services" WHERE "services"."online_booking" = 't' AND "services"."active" = 't'))) AND "locations"."company_id" IN (SELECT "companies"."id" FROM "companies" WHERE "companies"."active" = 't' AND "companies"."owned" = 't' AND "companies"."id" IN (SELECT "company_settings"."company_id" FROM "company_settings" WHERE "company_settings"."activate_search" = 't' AND "company_settings"."activate_workflow" = 't')) AND "locations"."active" = 't' AND (sqrt((latitude - latitudeInput)^2 + (longitude - longitudeInput)^2) < 0.25) ORDER BY pg_search_rank DESC, "locations"."id" ASC;

				--Get unowned companies first

				DROP TABLE IF EXISTS unowned_locations;
				CREATE TEMP TABLE unowned_locations AS SELECT "locations".*, ((ts_rank((to_tsvector('simple', unaccent(coalesce(pg_search_1.pg_search_2::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_1.pg_search_3::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_4.pg_search_5::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_6.pg_search_7::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_8.pg_search_9::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_10.pg_search_11::text, '')))), (to_tsquery('simple', ''' ' || unaccent(searchInput) || ' ''' || ':*')), 0))) AS pg_search_rank FROM "locations" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("companies"."name"::text, ' ') AS pg_search_2, string_agg("companies"."web_address"::text, ' ') AS pg_search_3 FROM "locations" INNER JOIN "companies" ON "companies"."id" = "locations"."company_id" GROUP BY "locations"."id") pg_search_1 ON pg_search_1.id = "locations"."id" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("economic_sectors"."name"::text, ' ') AS pg_search_5 FROM "locations" INNER JOIN "companies" ON "companies"."id" = "locations"."company_id" INNER JOIN "company_economic_sectors" ON "company_economic_sectors"."company_id" = "companies"."id" INNER JOIN "economic_sectors" ON "economic_sectors"."id" = "company_economic_sectors"."economic_sector_id" GROUP BY "locations"."id") pg_search_4 ON pg_search_4.id = "locations"."id" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("economic_sectors_dictionaries"."name"::text, ' ') AS pg_search_7 FROM "locations" INNER JOIN "companies" ON "companies"."id" = "locations"."company_id" INNER JOIN "company_economic_sectors" ON "company_economic_sectors"."company_id" = "companies"."id" INNER JOIN "economic_sectors" ON "economic_sectors"."id" = "company_economic_sectors"."economic_sector_id" INNER JOIN "economic_sectors_dictionaries" ON "economic_sectors_dictionaries"."economic_sector_id" = "economic_sectors"."id" GROUP BY "locations"."id") pg_search_6 ON pg_search_6.id = "locations"."id" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("service_categories"."name"::text, ' ') AS pg_search_9 FROM "locations" INNER JOIN "service_providers" ON "service_providers"."location_id" = "locations"."id" AND "service_providers"."active" = 't' INNER JOIN "service_staffs" ON "service_staffs"."service_provider_id" = "service_providers"."id" INNER JOIN "services" ON "services"."id" = "service_staffs"."service_id" AND "services"."active" = 't' AND "services"."online_booking" = 't' INNER JOIN "service_categories" ON "service_categories"."id" = "services"."service_category_id" GROUP BY "locations"."id") pg_search_8 ON pg_search_8.id = "locations"."id" LEFT OUTER JOIN (SELECT "locations"."id" AS id, string_agg("services"."name"::text, ' ') AS pg_search_11 FROM "locations" INNER JOIN "service_providers" ON "service_providers"."location_id" = "locations"."id" AND "service_providers"."active" = 't' INNER JOIN "service_staffs" ON "service_staffs"."service_provider_id" = "service_providers"."id" INNER JOIN "services" ON "services"."id" = "service_staffs"."service_id" AND "services"."active" = 't' AND "services"."online_booking" = 't' GROUP BY "locations"."id") pg_search_10 ON pg_search_10.id = "locations"."id" WHERE ((similarity((unaccent(coalesce(pg_search_1.pg_search_2::text, '') || ' ' || coalesce(pg_search_1.pg_search_3::text, '') || ' ' || coalesce(pg_search_4.pg_search_5::text, '') || ' ' || coalesce(pg_search_6.pg_search_7::text, '') || ' ' || coalesce(pg_search_8.pg_search_9::text, '') || ' ' || coalesce(pg_search_10.pg_search_11::text, ''))), unaccent(searchInput)) >= 0.1) OR ((to_tsvector('simple', unaccent(coalesce(pg_search_1.pg_search_2::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_1.pg_search_3::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_4.pg_search_5::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_6.pg_search_7::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_8.pg_search_9::text, ''))) || to_tsvector('simple', unaccent(coalesce(pg_search_10.pg_search_11::text, '')))) @@ (to_tsquery('simple', ''' ' || unaccent(searchInput) || ' ''' || ':*')))) AND "locations"."online_booking" = 't' AND "locations"."id" IN (SELECT "service_providers"."location_id" FROM "service_providers" WHERE "service_providers"."active" = 't' AND "service_providers"."online_booking" = 't' AND "service_providers"."id" IN (SELECT "service_staffs"."service_provider_id" FROM "service_staffs" WHERE "service_staffs"."service_id" IN (SELECT "services"."id" FROM "services" WHERE "services"."online_booking" = 't' AND "services"."active" = 't'))) AND "locations"."company_id" IN (SELECT "companies"."id" FROM "companies" WHERE "companies"."active" = 't' AND "companies"."owned" = 'f' AND "companies"."id" IN (SELECT "company_settings"."company_id" FROM "company_settings" WHERE "company_settings"."activate_search" = 't' AND "company_settings"."activate_workflow" = 't')) AND "locations"."active" = 't' AND (sqrt((latitude - latitudeInput)^2 + (longitude - longitudeInput)^2) < 0.25) ORDER BY pg_search_rank DESC, "locations"."id" ASC;

				owned_count:= (SELECT COUNT(id) from owned_locations);
				unowned_count:= (SELECT COUNT(id) from unowned_locations);

				owned_index:= 0;

				WHILE owned_index < owned_count LOOP

					FOR owned_location in
						SELECT * FROM owned_locations ORDER BY (sqrt((latitude - latitudeInput)^2 + (longitude - longitudeInput)^2)) ASC OFFSET owned_index LIMIT 5
					LOOP
						location_id:= owned_location.id;
						RETURN NEXT;
					END LOOP;

					owned_index:= owned_index + 5;

				END LOOP;

				unowned_index:= 0;

				WHILE unowned_index < unowned_count LOOP

					FOR unowned_location in
						SELECT * FROM unowned_locations ORDER BY (sqrt((latitude - latitudeInput)^2 + (longitude - longitudeInput)^2)) ASC OFFSET unowned_index LIMIT 5
					LOOP
						location_id:= unowned_location.id;
						RETURN NEXT;
					END LOOP;

					unowned_index:= unowned_index + 5;

				END LOOP;

			END
			$$ LANGUAGE plpgsql;
	  	__EOI
  	end

  	def self.down
	 	execute "DROP FUNCTION IF EXISTS locations_search(searchInput varchar, latitudeInput double precision, longitudeInput double precision)"
	end

end
