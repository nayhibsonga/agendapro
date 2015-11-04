class CreatePettyTransactions < ActiveRecord::Migration
  def change
    create_table :petty_transactions do |t|
      t.integer :petty_cash_id
      t.integer :transactioner_id
      t.integer :transactioner_type
      t.datetime :date
      t.float :amount, default: 0.0
      t.boolean :is_income, default: true

      t.timestamps
    end
  end
end
