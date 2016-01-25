class AddDescriptionToFiles < ActiveRecord::Migration
  def change
  	add_column :client_files, :description, :text, default: ""
  	add_column :company_files, :description, :text, default: ""
  end
end
