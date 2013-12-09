class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.timestamp :start
      t.timestamp :end
      t.text :notes
      t.integer :staff_id
      t.integer :user_id
      t.integer :location_id
      t.integer :status_id
      t.integer :promotion_id

      t.timestamps
    end
  end
end
