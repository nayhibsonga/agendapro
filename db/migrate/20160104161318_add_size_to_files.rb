class AddSizeToFiles < ActiveRecord::Migration
  def change
  	add_column :client_files, :size, :integer, default: 0
  	add_column :company_files, :size, :integer, default: 0
  end
end
