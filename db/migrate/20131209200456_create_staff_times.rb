class CreateStaffTimes < ActiveRecord::Migration
  def change
    create_table :staff_times do |t|
      t.time :open, :null => false
      t.time :close, :null => false
      t.references :staff, :null => false
      t.references :day, :null => false

      t.timestamps
    end
  end
end
