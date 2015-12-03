class CreateTreatmentPromoLocations < ActiveRecord::Migration
  def change
    create_table :treatment_promo_locations do |t|
      t.integer :treatment_promo_id
      t.integer :location_id

      t.timestamps
    end
  end
end
