class AddPaymentAccountIdToPayedBookings < ActiveRecord::Migration
  def change
  	add_column :payed_bookings, :payment_account_id, :integer
  end
end
