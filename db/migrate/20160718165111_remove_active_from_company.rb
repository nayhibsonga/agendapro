class RemoveActiveFromCompany < ActiveRecord::Migration
  def change
  	remove_column :companies, :active, :boolean
  end
end
