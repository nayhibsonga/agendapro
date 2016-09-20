class AddOverCapacityToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :schedule_overcapacity, :boolean, :default => true, :null => false
    add_column :company_settings, :provider_overcapacity, :boolean, :default => true, :null => false
    add_column :company_settings, :resource_overcapacity, :boolean, :default => true, :null => false
  end
end
