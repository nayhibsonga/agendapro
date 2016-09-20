class CreatePaymentProducts < ActiveRecord::Migration
  def change
    create_table :payment_products do |t|
      t.references :payment, index: true, null: false
      t.references :product, index: true, null: false
      t.float :price, default: 0
      t.float :discount, default: 0

      t.timestamps
    end
  end
end
