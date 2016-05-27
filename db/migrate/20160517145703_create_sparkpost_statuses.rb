class CreateSparkpostStatuses < ActiveRecord::Migration
  def change
    create_table :sparkpost_statuses do |t|
      t.string :event_type
      t.string :status
      t.integer :progress, default: 0
      t.boolean :blacklist, default: false

      t.timestamps
    end
  end
end
