class DropLocationOutcallDistricts < ActiveRecord::Migration
  def change
    drop_table :location_outcall_districts do |t|
      t.references :location, null: false
      t.references :districts, null: false
      t.timestamps null: false
    end
  end
end
