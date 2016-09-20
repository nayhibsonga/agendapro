class CreateResourceLocations < ActiveRecord::Migration
  def change
    create_table :resource_locations do |t|
      t.references :resource, index: true
      t.references :location, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
