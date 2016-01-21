class AddShowPriceToBundles < ActiveRecord::Migration
  def change
    add_column :bundles, :show_price, :boolean, default: true
  end
end
