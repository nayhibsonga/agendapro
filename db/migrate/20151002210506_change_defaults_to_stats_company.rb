class ChangeDefaultsToStatsCompany < ActiveRecord::Migration
  def change
  	change_column :stats_companies, :company_start, :datetime, null: true
  	change_column :stats_companies, :last_booking, :datetime, null: true
  	change_column :stats_companies, :last_payment, :datetime, null: true
  end
end
