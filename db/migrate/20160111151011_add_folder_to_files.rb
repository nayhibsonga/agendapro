class AddFolderToFiles < ActiveRecord::Migration
  def change
  	add_column :company_files, :folder, :string, default: ""
  	add_column :client_files, :folder, :string, default: ""
  end
end
