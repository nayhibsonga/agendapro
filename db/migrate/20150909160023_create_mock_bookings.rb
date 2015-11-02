class CreateMockBookings < ActiveRecord::Migration
  def change
    create_table :mock_bookings do |t|
      t.integer :client_id
      t.integer :service_id
      t.integer :service_provider_id
      t.float :price
      t.float :discount

      t.timestamps
    end
  end
end
