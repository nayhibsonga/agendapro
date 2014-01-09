class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, :null => false
      t.references :economic_sector, :index => true, :null => false

      t.timestamps
    end
  end
end
