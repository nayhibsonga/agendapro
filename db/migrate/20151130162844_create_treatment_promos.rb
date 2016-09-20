class CreateTreatmentPromos < ActiveRecord::Migration
  def change
    create_table :treatment_promos do |t|
      t.integer :location_id
      t.float :discount, default: 0
      t.datetime :finish_date
      t.datetime :book_limit_date
      t.integer :max_bookings, default: 0
      t.boolean :limit_booking, default: false

      t.timestamps
    end
  end
end
