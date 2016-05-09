class AddRequireCashierCodeToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :require_cashier_code, :boolean, default: true
  end
end
