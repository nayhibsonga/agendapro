class RemoveStockDefaultFromLocation < ActiveRecord::Migration
  def change
  	remove_column :locations, :default_stock_limit, :integer
  end
end
