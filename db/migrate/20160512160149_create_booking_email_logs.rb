class CreateBookingEmailLogs < ActiveRecord::Migration
  def change
    create_table :booking_email_logs do |t|
      t.references :booking, index: true
      t.string :transmission_id
      t.string :status
      t.string :subject
      t.string :recipient
      t.datetime :timestamp
      t.integer :opens, default: 0
      t.integer :clicks, default: 0

      t.timestamps
    end
  end
end
