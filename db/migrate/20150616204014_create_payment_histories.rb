class CreatePaymentHistories < ActiveRecord::Migration
  def change
    create_table :payment_histories do |t|
      t.date :payment_date
      t.float :amount, default: 0
      t.float :discount, default: 0
      t.references :payment_method, index: true
      t.references :user, index: true
      t.text :notes, default: ''

      t.timestamps
    end
  end
end
