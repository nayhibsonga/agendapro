class ChangeOnlineCancelationPolicy < ActiveRecord::Migration
  def change
  	remove_column :online_cancelation_policies, :cancel_max_hours, :float
  	add_column :online_cancelation_policies, :cancel_max, :integer
  	add_column :online_cancelation_policies, :cancel_unit, :string
  	remove_column :online_cancelation_policies, :modification_max, :float
  	add_column :online_cancelation_policies, :modification_max, :integer
  	remove_column :online_cancelation_policies, :min_hours, :float
  	add_column :online_cancelation_policies, :min_hours, :integer
  end
end
