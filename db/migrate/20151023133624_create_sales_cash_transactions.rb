class CreateSalesCashTransactions < ActiveRecord::Migration
  def change
    create_table :sales_cash_transactions do |t|
      t.integer :sales_cash_id
      t.integer :user_id
      t.float :amount, default: 0.0
      t.datetime :date, default: DateTime.now
      t.text :notes, default: ""
      t.string :receipt_number
      t.boolean :is_internal_transaction, default: false

      t.timestamps
    end
  end
end
