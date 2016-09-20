class CreateLocationOpenDays < ActiveRecord::Migration
  def change
    create_table :location_open_days do |t|
      t.references :location, index: true
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
