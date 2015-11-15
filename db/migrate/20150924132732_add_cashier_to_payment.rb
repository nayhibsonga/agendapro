class AddCashierToPayment < ActiveRecord::Migration
  def change
  	add_column :payments, :cashier_id, :integer
  end
end
