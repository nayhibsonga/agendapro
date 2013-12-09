class CreateLocationTimes < ActiveRecord::Migration
  def change
    create_table :location_times do |t|
      t.time :open
      t.time :close
      t.integer :location_id
      t.integer :day_id

      t.timestamps
    end
  end
end
