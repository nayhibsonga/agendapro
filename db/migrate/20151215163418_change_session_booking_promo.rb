class ChangeSessionBookingPromo < ActiveRecord::Migration
  def change
  	remove_column :session_bookings, :service_promo_id, :integer
  	add_column :session_bookings, :treatment_promo_id, :integer
  end
end
