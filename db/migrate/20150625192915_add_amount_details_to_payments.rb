class AddAmountDetailsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :bookings_amount, :float, default: 0
    add_column :payments, :bookings_discount, :float, default: 0
    add_column :payments, :products_amount, :float, default: 0
    add_column :payments, :products_discount, :float, default: 0
  end
end
