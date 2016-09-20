class AddQuantityToPaymentProducts < ActiveRecord::Migration
  def change
    add_column :payment_products, :quantity, :integer, default: 1, null: false
  end
end
