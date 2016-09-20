class ChangePayedBookingsCard < ActiveRecord::Migration
  def change
  	remove_column :payed_bookings, :booking_id, :integer
  	add_column :bookings, :payed_booking_id, :integer
  end
end
