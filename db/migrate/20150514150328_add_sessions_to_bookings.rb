class AddSessionsToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :is_session, :boolean, default: false
  	add_column :bookings, :session_number, :integer, default: nil
  	add_column :bookings, :session_booking_id, :integer
  	add_column :bookings, :user_session_confirmed, :boolean, default: false
  end
end
