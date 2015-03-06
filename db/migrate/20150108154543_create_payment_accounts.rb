class CreatePaymentAccounts < ActiveRecord::Migration
  def change
    create_table :payment_accounts do |t|
      t.string :name
      t.string :rut
      t.string :number
      t.float :amount
      t.integer :bank_code
      t.integer :type
      t.integer :currency
      t.integer :origin
      t.integer :destiny

      t.timestamps
    end
  end
end
