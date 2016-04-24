class CreatePaymentSendings < ActiveRecord::Migration
  def change
    create_table :payment_sendings do |t|
      t.references :payment, index: true
      t.string :emails
    end
  end
end
