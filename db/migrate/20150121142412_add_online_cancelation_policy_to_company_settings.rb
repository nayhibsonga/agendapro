class AddOnlineCancelationPolicyToCompanySettings < ActiveRecord::Migration
  def change
  	add_column :company_settings, :online_cancelation_policy_id, :integer
  	add_column :online_cancelation_policies, :min_hours, :float, default: 12
  end
end
