class CreateServicePaymentLogs < ActiveRecord::Migration
  def change
    create_table :service_payment_logs do |t|
      t.string :token
      t.string :trx_id
      t.references :service, :null => false
      t.references :company, :null => false
      t.decimal :amount, :null => false
      t.references :transaction_type, :index => true, :null => false

      t.timestamps
    end
  end
end
