class AddEditablePaymentPricesToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :editable_payment_prices, :boolean, default: true
  end
end
