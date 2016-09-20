class AddNewPlanMonthsToTransfer < ActiveRecord::Migration
  def change
  	add_column :billing_wire_transfers, :paid_months, :integer
  end
end
