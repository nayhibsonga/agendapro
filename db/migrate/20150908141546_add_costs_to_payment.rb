class AddCostsToPayment < ActiveRecord::Migration
  def change
  	add_column :payments, :paid_amount, :float, default: 0.0
  	add_column :payments, :change_amount, :float, default: 0.0
  end
end
