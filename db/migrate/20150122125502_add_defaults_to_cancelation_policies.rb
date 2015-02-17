class AddDefaultsToCancelationPolicies < ActiveRecord::Migration
  def change
  	change_column :online_cancelation_policies, :cancelable, :boolean, default: true
  	change_column :online_cancelation_policies, :modifiable, :boolean, default: true
  	change_column :online_cancelation_policies, :cancel_max, :integer, default: 1
  	change_column :online_cancelation_policies, :modification_max, :integer, default: 1
  	change_column :online_cancelation_policies, :min_hours, :integer, default: 12
  end
end
