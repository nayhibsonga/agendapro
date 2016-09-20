class ChangeDefaultsToPayments < ActiveRecord::Migration
  def change
  	change_column :payments, :notes, :text, default: ""
  	change_column :payments, :discount, :float, default: 0
  	change_column :products, :name, :text, default: ""
  	change_column :products, :description, :text, default: ""
  	change_column :products, :price, :text, default: 0
  end
end
