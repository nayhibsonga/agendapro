class AddReceiptToBooking < ActiveRecord::Migration
  def change
  	add_column :bookings, :receipt_id, :integer
  end
end
