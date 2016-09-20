class ChangeSearchSettingDefault < ActiveRecord::Migration
  def change
  	change_column :company_settings, :activate_search, :boolean, :default => false
  end
end
