class AddNumberToPettyTransactions < ActiveRecord::Migration
  def change
  	add_column :petty_transactions, :receipt_number, :string
  end
end
