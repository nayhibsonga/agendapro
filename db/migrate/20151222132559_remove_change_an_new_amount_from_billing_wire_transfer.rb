class RemoveChangeAnNewAmountFromBillingWireTransfer < ActiveRecord::Migration
  def change
  	remove_column :billing_wire_transfers, :change_plan_amount, :float
  	remove_column :billing_wire_transfers, :new_plan_amount, :float
  end
end
