class AddQuantityToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :products_quantity, :integer, default: 0
    add_column :payments, :bookings_quantity, :integer, default: 0
    add_column :payments, :quantity, :integer, default: 0
  end
end
