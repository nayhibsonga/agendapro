class CreateLocationOutcallDistricts < ActiveRecord::Migration
  def change
    create_table :location_outcall_districts do |t|
      t.references :location, index: true
      t.references :district, index: true

      t.timestamps
    end
  end
end
