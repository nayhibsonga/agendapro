class FixCancelation < ActiveRecord::Migration
  def change
  	remove_column :online_cancelation_policies, :company_settings_id, :integer
  	add_column :online_cancelation_policies, :company_setting_id, :integer
  end
end
