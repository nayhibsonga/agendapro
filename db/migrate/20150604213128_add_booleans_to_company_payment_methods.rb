class AddBooleansToCompanyPaymentMethods < ActiveRecord::Migration
  def change
  	add_column :company_payment_methods, :active, :boolean, default: true
  	add_column :company_payment_methods, :number_required, :boolean, default: true
  end
end
