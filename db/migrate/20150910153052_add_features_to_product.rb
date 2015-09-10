class AddFeaturesToProduct < ActiveRecord::Migration
  def change
  	add_column :products, :brand_id, :integer
  	add_column :products, :display, :string
  	add_column :products, :cost, :float
  	add_column :products, :internal_price, :float
  end
end
