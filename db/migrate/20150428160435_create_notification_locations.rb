class CreateNotificationLocations < ActiveRecord::Migration
  def change
    create_table :notification_locations do |t|
      t.references :location, index: true
      t.references :notification_email, index: true

      t.timestamps
    end
  end
end
