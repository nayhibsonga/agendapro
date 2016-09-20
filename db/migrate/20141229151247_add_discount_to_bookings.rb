class AddDiscountToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :has_discount, :boolean, default: false
  	add_column :bookings, :discount, :float, default: 0
  end
end
