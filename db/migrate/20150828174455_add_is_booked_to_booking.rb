class AddIsBookedToBooking < ActiveRecord::Migration
  def change
  	add_column :bookings, :is_booked, :boolean, default: true
  end
end
