class FixDisplayForProduct < ActiveRecord::Migration
  def change
  	remove_column :products, :display, :string
  	add_column :products, :product_display_id, :integer
  end
end
