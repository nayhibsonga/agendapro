class AddSessionAmountsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :sessions_amount, :float, default: 0
    add_column :payments, :sessions_discount, :float, default: 0
    add_column :payments, :sessions_quantity, :integer, default: 0
  end
end
