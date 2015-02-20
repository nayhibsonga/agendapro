class FixCancelationPolicyAssociation < ActiveRecord::Migration
  def change
  	remove_column :company_settings, :online_cancelation_policy_id, :integer
  	add_column :online_cancelation_policies, :company_settings_id, :integer
  end
end
