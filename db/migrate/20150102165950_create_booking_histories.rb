class CreateBookingHistories < ActiveRecord::Migration
  def change
    create_table :booking_histories do |t|
      t.references :booking, index: true
      t.string :action
      t.references :staff_code, index: true
      t.datetime :start
      t.references :status, index: true
      t.references :service, index: true
      t.references :service_provider, index: true

      t.timestamps
    end
  end
end
