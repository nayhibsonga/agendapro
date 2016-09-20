class AddPlanInfoToBillingWireTransfer < ActiveRecord::Migration
  def change
  	add_column :billing_wire_transfers, :change_plan, :boolean, default: false
  	add_column :billing_wire_transfers, :new_plan, :integer
  	add_column :billing_wire_transfers, :change_plan_amount, :float, default: 0
  	add_column :billing_wire_transfers, :new_plan_amount, :float, default: 0
  end
end
