class AddTransferCompleteToPayedBooking < ActiveRecord::Migration
  def change
  	add_column :payed_bookings, :transfer_complete, :boolean, default: false
  end
end
