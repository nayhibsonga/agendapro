class AddReciptIdToPaymentProduct < ActiveRecord::Migration
  def change
  	if !column_exists?(:payment_products, :receipt_id)
  		add_column :payment_products, :receipt_id, :integer
  	end
  end
end
