class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :adress
      t.string :phone
      t.float :latitude
      t.float :longitude
      t.integer :district_id
      t.integer :company_id

      t.timestamps
    end
  end
end
