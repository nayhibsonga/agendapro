class CheckPromoHourStoredProcedure < ActiveRecord::Migration
  def self.up
  	execute <<-__EOI
			CREATE OR REPLACE FUNCTION check_promo_hour(local_id int, provider_id int, serv_id int, start_date timestamp, end_date timestamp)
			returns BOOLEAN
			AS 
			$$
			DECLARE

			BEGIN
			  IF not exists (select id from services where services.id = serv_id AND services.has_time_discount = TRUE AND services.online_payable = TRUE AND services.time_promo_active = TRUE AND (select exists (select id from company_settings where company_id = services.company_id AND company_settings.online_payment_capable = TRUE AND company_settings.promo_offerer_capable = TRUE))) THEN
			  	return FALSE;
			  END IF;

			  -- IF select 
			 
			  return true;

			END
			$$ LANGUAGE plpgsql;
		__EOI
 end
 def self.down
   execute "DROP FUNCTION IF EXISTS check_promo_hour(local_id int, provider_id int, serv_id int, start_date timestamp, end_date timestamp)"
 end
end
