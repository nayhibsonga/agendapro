class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.integer :payment_id
      t.integer :payment_method_id
      t.integer :company_payment_method_id
      t.string :number, default: ""
      t.float :amount, default: 0
      t.integer :installments, default: 0
      t.integer :payment_method_type_id
      t.integer :bank_id

      t.timestamps
    end
  end
end
