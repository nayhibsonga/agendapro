class CreateClientFiles < ActiveRecord::Migration
  def change
    create_table :client_files do |t|
      t.integer :client_id
      t.text :name
      t.text :full_path
      t.text :public_url

      t.timestamps
    end
  end
end
