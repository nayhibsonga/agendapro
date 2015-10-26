class AddParametersToPayUConfirmations < ActiveRecord::Migration
  def change
  	add_column :pay_u_notifications, :cc_number, :string
  	add_column :pay_u_notifications, :cc_holder, :string
  	add_column :pay_u_notifications, :bank_referenced_name, :string
  	add_column :pay_u_notifications, :payment_method_name, :string
  	add_column :pay_u_notifications, :antifraudMerchantId, :string
  end
end
