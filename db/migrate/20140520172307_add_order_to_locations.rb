class AddOrderToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :order, :integer, :default => 0
  end
end
