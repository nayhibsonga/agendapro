class AddMaxDiscountToSessionBooking < ActiveRecord::Migration
  def change
  	add_column :session_bookings, :max_discount, :float, default: 0.0
  end
end
