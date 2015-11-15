class AddSellerToPaymentProduct < ActiveRecord::Migration
  def change
  	add_column :payment_products, :seller_id, :integer
  	add_column :payment_products, :seller_type, :integer
  end
end
