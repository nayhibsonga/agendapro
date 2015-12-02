class AddTrialLeftToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :trial_months_left, :integer, default: 0
  end
end
