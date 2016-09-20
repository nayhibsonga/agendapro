class AddPettyTransactionIdToSalesCashTransaction < ActiveRecord::Migration
  def change
  	add_column :sales_cash_transactions, :petty_transaction_id, :integer
  end
end
