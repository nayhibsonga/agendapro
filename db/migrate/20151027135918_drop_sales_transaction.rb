class DropSalesTransaction < ActiveRecord::Migration
  def change
  	drop_table :sales_transactions
  end
end
