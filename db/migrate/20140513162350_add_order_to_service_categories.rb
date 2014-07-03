class AddOrderToServiceCategories < ActiveRecord::Migration
  def change
    add_column :service_categories, :order, :integer, :default => 0
  end
end
