class AddShowInHomeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :show_in_home, :boolean, default: false
  end
end
