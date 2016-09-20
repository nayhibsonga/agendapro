class AddDefaultToStrings < ActiveRecord::Migration
  def change
  	change_column :companies, :description, :text, default: ""
  	change_column :companies, :cancellation_policy, :text, default: ""
  	change_column :clients, :email, :string, default: ""
  	change_column :clients, :first_name, :string, default: ""
  	change_column :clients, :last_name, :string, default: ""
  	change_column :clients, :phone, :string, default: ""
  	change_column :clients, :address, :string, default: ""
  	change_column :clients, :district, :string, default: ""
  	change_column :clients, :city, :string, default: ""
  	change_column :clients, :identification_number, :string, default: ""
  	change_column :clients, :record, :string, default: ""
  	change_column :clients, :second_phone, :string, default: ""
  	change_column :company_settings, :deal_name, :string, default: ""
  	change_column :locations, :second_address, :string, default: ""
  	change_column :provider_breaks, :name, :string, default: ""
  	change_column :users, :phone, :string, default: ""
  end
end
