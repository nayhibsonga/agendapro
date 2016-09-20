class CreateBillingWireTransfers < ActiveRecord::Migration
  def change
    create_table :billing_wire_transfers do |t|
      t.datetime :payment_date, default: DateTime.now
      t.float :amount, default: 0
      t.string :receipt_number, default: ""
      t.string :account_name, default: ""
      t.string :account_bank, default: ""
      t.string :account_number, default: ""
      t.boolean :approved, default: false
      t.integer :company_id
      
      t.timestamps
    end
  end
end
