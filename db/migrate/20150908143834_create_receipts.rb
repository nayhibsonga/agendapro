class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.integer :receipt_type_id
      t.integer :payment_id
      t.float :amount

      t.timestamps
    end
  end
end
