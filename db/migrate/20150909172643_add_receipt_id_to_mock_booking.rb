class AddReceiptIdToMockBooking < ActiveRecord::Migration
  def change
  	add_column :mock_bookings, :receipt_id, :integer
  end
end
