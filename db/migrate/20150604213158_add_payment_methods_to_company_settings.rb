class AddPaymentMethodsToCompanySettings < ActiveRecord::Migration
  def change
  	add_column :company_settings, :receipt_required, :boolean, default: true
  end
end
