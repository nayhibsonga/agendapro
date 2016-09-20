class AddPaymentIdToMockBooking < ActiveRecord::Migration
  def change
  	add_column :mock_bookings, :payment_id, :integer
  end
end
