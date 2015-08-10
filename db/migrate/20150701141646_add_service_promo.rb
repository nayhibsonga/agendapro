class AddServicePromo < ActiveRecord::Migration
  def change
  	remove_column :promos, :service_id, :integer
  	add_column :promos, :service_promo_id, :integer
  	add_column :services, :active_service_promo_id, :integer
  	add_column :bookings, :service_promo_id, :integer
  	add_column :session_bookings, :service_promo_id, :integer
  end
end
