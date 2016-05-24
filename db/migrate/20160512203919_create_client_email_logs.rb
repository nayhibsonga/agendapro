class CreateClientEmailLogs < ActiveRecord::Migration
  def change
    create_table :client_email_logs do |t|
      t.references :client, index: true
      t.integer :campaign_id
      t.string :transmission_id, default: ''
      t.string :status, default: ''
      t.string :subject, default: ''
      t.string :recipient, default: ''
      t.datetime :timestamp
      t.integer :opens, default: 0
      t.integer :clicks, default: 0

      t.timestamps
    end
  end
end
