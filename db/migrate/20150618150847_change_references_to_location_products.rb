class ChangeReferencesToLocationProducts < ActiveRecord::Migration
  def change
  	rename_column :location_products, :product_id_id, :product_id
  	rename_column :location_products, :location_id_id, :location_id
  end
end
