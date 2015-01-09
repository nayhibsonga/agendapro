class FixPaymentAccount < ActiveRecord::Migration
  def change
  	remove_column :payment_accounts, :type, :integer
  	add_column :payment_accounts, :account_type, :integer, default: 3
  end
end
