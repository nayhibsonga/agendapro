class CreateServiceTimes < ActiveRecord::Migration
  def change
    create_table :service_times do |t|
      t.time :open, null: false
      t.time :close, null: false
      t.references :service, index: true
      t.references :day, index: true, null: false

      t.timestamps
    end
  end
end
