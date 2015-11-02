class AddListPriceToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :list_price, :float, default: 0
  end
end
