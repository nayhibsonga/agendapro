class AddExclusiveToFilters < ActiveRecord::Migration
  def change
  	add_column :numeric_custom_filters, :exclusive1, :boolean, default: true
  	add_column :numeric_custom_filters, :exclusive2, :boolean, default: true
  	add_column :date_custom_filters, :exclusive1, :boolean, default: true
  	add_column :date_custom_filters, :exclusive2, :boolean, default: true
  end
end
