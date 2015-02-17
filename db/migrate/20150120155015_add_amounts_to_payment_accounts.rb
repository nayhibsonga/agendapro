class AddAmountsToPaymentAccounts < ActiveRecord::Migration
  def change
  	add_column :payment_accounts, :company_amount, :float, default: 0
  	add_column :payment_accounts, :gain_amount, :float, default: 0
  end
end
