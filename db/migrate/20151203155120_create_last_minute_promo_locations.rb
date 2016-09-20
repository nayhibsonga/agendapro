class CreateLastMinutePromoLocations < ActiveRecord::Migration
  def change
    create_table :last_minute_promo_locations do |t|
      t.integer :last_minute_promo_id
      t.integer :location_id

      t.timestamps
    end
  end
end
