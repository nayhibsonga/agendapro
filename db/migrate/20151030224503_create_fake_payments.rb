class CreateFakePayments < ActiveRecord::Migration
  def change
    create_table :fake_payments do |t|
      t.integer :company_id
      t.float :amount
      t.integer :receipt_type_id
      t.string :receipt_number
      t.integer :payment_method_id
      t.string :payment_method_number
      t.integer :payment_method_type_id
      t.integer :installments
      t.boolean :payed
      t.date :payment_date
      t.integer :bank_id
      t.integer :company_payment_method_id
      t.float :discount
      t.text :notes
      t.integer :location_id
      t.integer :client_id
      t.float :bookings_amount
      t.float :bookings_discount
      t.float :products_amount
      t.float :products_discount
      t.integer :products_quantity
      t.integer :bookings_quantity
      t.integer :quantity
      t.float :sessions_amount
      t.float :sessions_discount
      t.integer :sessions_quantity

      t.timestamps
    end
  end
end
