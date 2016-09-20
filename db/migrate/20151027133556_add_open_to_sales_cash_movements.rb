class AddOpenToSalesCashMovements < ActiveRecord::Migration
  def change
  	add_column :sales_cash_transactions, :open, :boolean, default: true
  	add_column :sales_cash_incomes, :open, :boolean, default: true
  end
end
