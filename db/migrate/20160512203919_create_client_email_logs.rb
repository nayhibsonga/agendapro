class CreateClientEmailLogs < ActiveRecord::Migration
  def change
    create_table :client_email_logs do |t|
      t.references :client, index: true
      t.integer :campaign_id
      t.string :transmission_id
      t.string :status
      t.string :subject
      t.string :recipient
      t.date_time :timestamp
      t.integer :opens, default: 0
      t.integer :clicks, default: 0

      t.timestamps
    end
  end
end
