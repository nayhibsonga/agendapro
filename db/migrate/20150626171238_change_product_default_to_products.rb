class ChangeProductDefaultToProducts < ActiveRecord::Migration
  def change
  	change_column :products, :price, 'float USING CAST(price AS float)', default: 0
  end
end
