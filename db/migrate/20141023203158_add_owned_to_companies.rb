class AddOwnedToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :owned, :boolean, default: true
  end
end
