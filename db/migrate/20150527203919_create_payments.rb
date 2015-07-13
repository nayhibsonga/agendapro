class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :company, index: true
      t.float :amount, default: 0
      t.references :receipt_type, index: true
      t.string :receipt_number, null: false, default: ""
      t.references :payment_method, index: true
      t.string :payment_method_number, null: false, default: ""
      t.references :payment_method_type, index: true
      t.integer :installments
      t.boolean :payed, default: false
      t.date :payment_date
      t.references :bank, index: true

      t.timestamps
    end
  end
end
