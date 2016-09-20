class AddTransactionTypeToBillingRecord < ActiveRecord::Migration
  def change
  	add_column :billing_records, :transaction_type_id, :integer
  end
end
