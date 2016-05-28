class AddSssionBookingIndexInBookings < ActiveRecord::Migration
  def change
    add_index :bookings, :session_booking_id
  end
end
