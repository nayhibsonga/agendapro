class AddStatusToPaymentAccount < ActiveRecord::Migration
  def change
  	add_column :payment_accounts, :status, :boolean, default: false
  	change_column :payment_accounts, :currency, :integer, default: 0
  	change_column :payment_accounts, :origin, :integer, default: 1
  	change_column :payment_accounts, :destiny, :integer, default: 1
  end
end
