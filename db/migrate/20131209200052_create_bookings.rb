class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.timestamp :start, :null => false
      t.timestamp :end, :null => false
      t.text :notes
      t.references :service_provider, :null => false
      t.references :user, :null => false
      t.references :service, :null => false
      t.references :location, :null => false
      t.references :status, :null => false
      t.references :promotion

      t.timestamps
    end
  end
end
