class CreateLastMinutePromos < ActiveRecord::Migration
  def change
    create_table :last_minute_promos do |t|
      t.integer :discount, default: 0
      t.integer :hours, default: 0
      t.integer :location_id
      t.integer :service_id

      t.timestamps
    end
  end
end
