class AddShowOptionsToAttribute < ActiveRecord::Migration
  def change
  	add_column :attributes, :show_on_calendar, :boolean, default: false
  	add_column :attributes, :show_on_workflow, :boolean, default: false
  	add_column :attributes, :mandatory_on_calendar, :boolean, default: false
  	add_column :attributes, :mandatory_on_workflow, :boolean, default: false
  end
end
