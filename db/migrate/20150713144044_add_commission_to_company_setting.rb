class AddCommissionToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :online_payment_commission, :integer, default: 5.0
  end
end
