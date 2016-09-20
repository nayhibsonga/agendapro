class AddAmountToPlanLog < ActiveRecord::Migration
  def change
    add_column :plan_logs, :amount, :float, null: false, default: 0.0
  end
end
