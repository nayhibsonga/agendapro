class AddIsSessionBookedToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :is_session_booked, :boolean, default: false
  end
end
