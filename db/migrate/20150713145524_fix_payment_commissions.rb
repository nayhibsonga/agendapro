class FixPaymentCommissions < ActiveRecord::Migration
  def change
  	remove_column :company_settings, :online_payment_commission, :integer
  	add_column :company_settings, :online_payment_commission, :float, default: 5.0
  end
end
