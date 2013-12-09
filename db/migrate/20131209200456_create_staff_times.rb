class CreateStaffTimes < ActiveRecord::Migration
  def change
    create_table :staff_times do |t|
      t.time :open
      t.time :close
      t.integer :staff_id
      t.integer :day_id

      t.timestamps
    end
  end
end
