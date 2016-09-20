class AddDiscountToServices < ActiveRecord::Migration
  def change
  	add_column :services, :has_discount, :boolean, default: false
  	add_column :services, :discount, :float, default: 0
  	remove_column :bookings, :has_discount, :boolean
  	remove_column :bookings, :discount, :float
  end
end
