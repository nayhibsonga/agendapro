class CreateBillingLogs < ActiveRecord::Migration
  def change
    create_table :billing_logs do |t|
      t.float :payment
      t.float :amount
      t.date :next_payment
      t.integer :company_id
      t.integer :plan_id
      t.integer :transaction_type_id

      t.timestamps
    end
  end
end
