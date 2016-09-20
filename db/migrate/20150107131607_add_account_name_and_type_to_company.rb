class AddAccountNameAndTypeToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :account_name, :string, default: ""
  	add_column :companies, :account_type, :integer, default: 3
  end
end
