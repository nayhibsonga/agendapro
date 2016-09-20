class AddStartIndexToBookings < ActiveRecord::Migration
  def change
  	add_index :bookings, :start
  end
end
