class CreateSalesTransactions < ActiveRecord::Migration
  def change
    create_table :sales_transactions do |t|
      t.integer :sales_cash_id
      t.integer :transactioner_id
      t.integer :transactioner_type, default: 1
      t.datetime :date, default: DateTime.now
      t.float :amount, default: 0.0
      t.boolean :is_income, default: false
      t.text :notes, default: ""
      t.string :receipt_number, default: ""

      t.timestamps
    end
  end
end
