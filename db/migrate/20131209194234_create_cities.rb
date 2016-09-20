class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name, :null => false
      t.references :region, :index => true, :null => false

      t.timestamps
    end
  end
end
