class CreateReceiptProducts < ActiveRecord::Migration
  def change
    create_table :receipt_products do |t|
      t.integer :receipt_id
      t.integer :product_id
      t.float :price
      t.float :discount
      t.integer :quantity

      t.timestamps
    end
  end
end
