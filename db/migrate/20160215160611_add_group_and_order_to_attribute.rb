class AddGroupAndOrderToAttribute < ActiveRecord::Migration
  def change
  	add_column :attributes, :attribute_group_id, :integer
  	add_column :attributes, :order, :integer
  end
end
