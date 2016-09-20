class FixCancelationDefaults < ActiveRecord::Migration
  def change
  	change_column :online_cancelation_policies, :cancel_max, :integer, default: 24
  	change_column :online_cancelation_policies, :cancel_unit, :integer, default: 2
  end
end
