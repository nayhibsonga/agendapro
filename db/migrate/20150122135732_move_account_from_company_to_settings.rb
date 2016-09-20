class MoveAccountFromCompanyToSettings < ActiveRecord::Migration
  def change
  	remove_column :companies, :allows_online_payment, :boolean
  	remove_column :companies, :account_number, :string
  	remove_column :companies, :company_rut, :string
  	remove_column :companies, :account_name, :string
  	remove_column :companies, :account_type, :integer
  	remove_column :companies, :bank_id, :integer
  	add_column :company_settings, :allows_online_payment, :boolean, default: false
  	add_column :company_settings, :account_number, :string, default: ""
  	add_column :company_settings, :company_rut, :string, default: ""
  	add_column :company_settings, :account_name, :string, default: ""
  	add_column :company_settings, :account_type, :integer, default: 3
  	add_column :company_settings, :bank_id, :integer
  end
end
