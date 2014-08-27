class FixAmountCompany < ActiveRecord::Migration
  def change
  	rename_column :companies, :pay_due, :months_active_left
  end
end
