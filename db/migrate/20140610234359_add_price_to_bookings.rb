class AddPriceToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :price, :float
  end
end
