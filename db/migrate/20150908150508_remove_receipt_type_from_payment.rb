class RemoveReceiptTypeFromPayment < ActiveRecord::Migration
  def change
  	remove_column :payments, :receipt_type_id
  end
end
