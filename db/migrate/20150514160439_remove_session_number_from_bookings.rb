class RemoveSessionNumberFromBookings < ActiveRecord::Migration
  def change
  	remove_column :bookings, :session_number, :integer
  end
end
