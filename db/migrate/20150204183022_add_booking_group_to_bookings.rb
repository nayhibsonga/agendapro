class AddBookingGroupToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :booking_group, :integer
  end
end
