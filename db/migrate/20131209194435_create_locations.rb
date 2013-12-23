class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name, :null => false
      t.string :address, :null => false
      t.string :phone, :null => false
      t.float :latitude
      t.float :longitude
      t.references :district, :null => false
      t.references :company, :null => false

      t.timestamps
    end
  end
end
