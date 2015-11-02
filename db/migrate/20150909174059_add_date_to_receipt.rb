class AddDateToReceipt < ActiveRecord::Migration
  def change
  	add_column :receipts, :date, :date
  end
end
