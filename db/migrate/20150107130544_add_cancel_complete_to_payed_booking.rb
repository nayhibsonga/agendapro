class AddCancelCompleteToPayedBooking < ActiveRecord::Migration
  def change
  	add_column :payed_bookings, :cancel_complete, :boolean, default: false
  end
end
