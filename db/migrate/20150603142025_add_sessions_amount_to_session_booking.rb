class AddSessionsAmountToSessionBooking < ActiveRecord::Migration
  def change
  	add_column :session_bookings, :sessions_amount, :integer, default: 0
  end
end
