class AddDealExclusiveToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :deal_exclusive, :boolean, default: true
    add_column :company_settings, :quantity, :integer, default: 0
    add_column :company_settings, :constraint_option, :integer, default: 0
    add_column :company_settings, :constraint_quantity, :integer, default: 0
  end
end
