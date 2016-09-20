class FixProductBrandId < ActiveRecord::Migration
  def change
  	remove_column :products, :brand_id, :integer
  	add_column :products, :product_brand_id, :integer
  end
end
