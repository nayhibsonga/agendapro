class CreateSessionBookings < ActiveRecord::Migration
  def change
    create_table :session_bookings do |t|
      t.integer :sessions_taken
      t.integer :service_id
      t.integer :user_id

      t.timestamps
    end
  end
end
