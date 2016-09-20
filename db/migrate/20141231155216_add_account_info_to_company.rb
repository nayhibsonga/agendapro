class AddAccountInfoToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :allows_online_payment, :boolean, default: false
  	add_column :companies, :bank, :string, default: ""
  	add_column :companies, :account_number, :string, default: ""
  	add_column :companies, :company_rut, :string, default: ""
  end
end
