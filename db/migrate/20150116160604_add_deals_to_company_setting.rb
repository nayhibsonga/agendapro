class AddDealsToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :deal_activate, :boolean, default: false
    add_column :company_settings, :deal_name, :string
    add_column :company_settings, :deal_overcharge, :boolean, default: true
  end
end
