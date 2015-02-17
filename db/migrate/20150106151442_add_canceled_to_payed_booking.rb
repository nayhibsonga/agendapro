class AddCanceledToPayedBooking < ActiveRecord::Migration
  def change
  	add_column :payed_bookings, :canceled, :boolean, default: false
  end
end
