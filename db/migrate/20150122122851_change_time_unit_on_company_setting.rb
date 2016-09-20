class ChangeTimeUnitOnCompanySetting < ActiveRecord::Migration
  def change
  	remove_column :online_cancelation_policies, :modification_unit, :string
  	add_column :online_cancelation_policies, :modification_unit, :integer, default: 1
  	remove_column :online_cancelation_policies, :cancel_unit, :string
  	add_column :online_cancelation_policies, :cancel_unit, :integer, default: 1
  end
end
