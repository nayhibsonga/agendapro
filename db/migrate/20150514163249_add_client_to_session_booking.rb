class AddClientToSessionBooking < ActiveRecord::Migration
  def change
  	add_column :session_bookings, :client_id, :integer
  end
end
