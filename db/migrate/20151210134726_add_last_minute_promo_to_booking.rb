class AddLastMinutePromoToBooking < ActiveRecord::Migration
  def change
  	add_column :bookings, :last_minute_promo_id, :integer
  end
end
