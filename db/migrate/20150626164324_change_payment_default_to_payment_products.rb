class ChangePaymentDefaultToPaymentProducts < ActiveRecord::Migration
  def change
  	change_column :payment_products, :payment_id, :integer, null: true
  end
end
