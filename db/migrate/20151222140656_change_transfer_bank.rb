class ChangeTransferBank < ActiveRecord::Migration
  def change
  	remove_column :billing_wire_transfers, :account_bank, :string
  	add_column :billing_wire_transfers, :bank_id, :integer
  end
end
