class AddOnlinePaymentCapableToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :online_payment_capable, :boolean, default: false
  end
end
