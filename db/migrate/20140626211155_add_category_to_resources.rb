class AddCategoryToResources < ActiveRecord::Migration
  def change
  	remove_column :resources, :location_id
  	remove_column :resources, :quantity
  	add_reference :resources, :resource_category, index: true
  	add_reference :resources, :company, index: true
  end
end
