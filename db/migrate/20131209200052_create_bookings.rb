class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.timestamp :start, :null => false
      t.timestamp :end, :null => false
      t.text :notes
      t.references :service_provider, :index => true, :null => false
      t.references :user, :index => true
      t.references :service, :index => true, :null => false
      t.references :location, :index => true, :null => false
      t.references :status, :index => true, :null => false
      t.references :promotion, :index => true

      t.timestamps
    end
  end
end
