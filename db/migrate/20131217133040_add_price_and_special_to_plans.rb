class AddPriceAndSpecialToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :price, :float, :null => false, :default => 0
    add_column :plans, :special, :boolean, :default => false
  end
end
