class AddNotesToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :discount, :float, default: 0
    add_column :payments, :notes, :text, default: 0
  end
end
