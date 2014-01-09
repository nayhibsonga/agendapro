class CreateLocationTimes < ActiveRecord::Migration
  def change
    create_table :location_times do |t|
      t.time :open, :null => false
      t.time :close, :null => false
      t.references :location, :index => true, :null => false
      t.references :day, :index => true, :null => false

      t.timestamps
    end
  end
end
