class ChangeReceiptNumberFromPaymentToReceipt < ActiveRecord::Migration
  def change
  	add_column :receipts, :number, :string, default: ""
  	remove_column :payments, :receipt_number
  end
end
