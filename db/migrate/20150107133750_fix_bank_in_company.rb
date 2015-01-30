class FixBankInCompany < ActiveRecord::Migration
  def change
  	remove_column :companies, :bank
  	add_column :companies, :bank_id, :integer
  end
end
