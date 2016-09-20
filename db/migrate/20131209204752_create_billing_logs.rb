class CreateBillingLogs < ActiveRecord::Migration
  def change
    create_table :billing_logs do |t|
      t.float :payment, :null => false
      t.float :amount, :null => false
      t.date :next_payment, :null => false
      t.references :company, :index => true, :null => false
      t.references :plan, :index => true, :null => false
      t.references :transaction_type, :index => true, :null => false

      t.timestamps
    end
  end
end
