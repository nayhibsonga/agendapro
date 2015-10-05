class AddSalesUserToStatsCompany < ActiveRecord::Migration
  def change
  	add_column :stats_companies, :company_sales_user_id, :integer
  end
end
