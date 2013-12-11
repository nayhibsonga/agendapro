class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.timestamp :start, :null => false
      t.timestamp :end, :null => false
      t.text :notes
      t.references :staff, :null => false
      t.references :user, :null => false
      t.references :location, :null => false
      t.references :status, :null => false
      t.references :promotion, :null => false

      t.timestamps
    end
  end
end
