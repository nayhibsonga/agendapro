class AddCategoryToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :product_category, index: true, null: false
    add_column :products, :sku, :string, default: ''
  end
end
