class RemoveItemsNumbersFromPayment < ActiveRecord::Migration
  def change
  	remove_column :payments, :bookings_amount, :float
  	remove_column :payments, :bookings_quantity, :integer
  	remove_column :payments, :bookings_discount, :float
  	remove_column :payments, :sessions_amount, :float
  	remove_column :payments, :sessions_quantity, :integer
  	remove_column :payments, :sessions_discount, :float
  	remove_column :payments, :products_amount, :float
  	remove_column :payments, :products_quantity, :integer
  	remove_column :payments, :products_discount, :float
  end
end
