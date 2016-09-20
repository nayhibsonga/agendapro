class CreateFileAttributes < ActiveRecord::Migration
  def change
    create_table :file_attributes do |t|
      t.integer :attribute_id
      t.integer :client_id
      t.integer :client_file_id

      t.timestamps
    end
  end
end
