class RemoveReceiptNumberFromransfers < ActiveRecord::Migration
  def change
  	remove_column :billing_wire_transfers, :receipt_number, :string
  end
end
