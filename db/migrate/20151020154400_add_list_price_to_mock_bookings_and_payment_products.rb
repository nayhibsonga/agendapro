class AddListPriceToMockBookingsAndPaymentProducts < ActiveRecord::Migration
  def change
  	add_column :mock_bookings, :list_price, :float, default: 0.0
  	add_column :payment_products, :list_price, :float, default: 0.0
  end
end
