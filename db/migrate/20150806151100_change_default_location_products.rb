class ChangeDefaultLocationProducts < ActiveRecord::Migration
  def change
  	change_column :location_products, :product_id, :integer, null: true
  end
end
