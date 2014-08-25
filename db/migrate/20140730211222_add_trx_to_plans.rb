class AddTrxToPlans < ActiveRecord::Migration
  def change
    add_column :plan_logs, :trx_id, :string
  end
end
