class CreateNotificationProviders < ActiveRecord::Migration
  def change
    create_table :notification_providers do |t|
      t.references :provider, index: true
      t.references :notification_email, index: true

      t.timestamps
    end
  end
end
