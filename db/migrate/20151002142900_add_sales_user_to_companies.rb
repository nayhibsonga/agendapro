class AddSalesUserToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :sales_user_id, :integer
  end
end
