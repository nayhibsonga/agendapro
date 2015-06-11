class AddCompanyPaymentMethodToPayments < ActiveRecord::Migration
  def change
  	add_reference :payments, :company_payment_method, index: true
  end
end
