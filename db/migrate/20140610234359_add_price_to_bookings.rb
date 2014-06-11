class AddPriceToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :price, :float, :default => 0
  end
end
