class RenameDealToCompanySettings < ActiveRecord::Migration
  def change
    rename_column :company_settings, :quantity, :deal_quantity
    rename_column :company_settings, :constraint_option, :deal_constraint_option
    rename_column :company_settings, :constraint_quantity, :deal_constraint_quantity
  end
end
