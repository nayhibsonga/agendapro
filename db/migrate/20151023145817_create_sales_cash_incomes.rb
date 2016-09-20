class CreateSalesCashIncomes < ActiveRecord::Migration
  def change
    create_table :sales_cash_incomes do |t|
      t.integer :sales_cash_id
      t.integer :user_id
      t.float :amount, default: 0.0
      t.datetime :date, default: DateTime.now
      t.text :notes, default: ""

      t.timestamps
    end
  end
end
