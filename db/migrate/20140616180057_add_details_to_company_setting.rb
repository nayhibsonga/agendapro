class AddDetailsToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :activate_search, :boolean, :default => true
    add_column :company_settings, :activate_workflow, :boolean, :default => true
  end
end
