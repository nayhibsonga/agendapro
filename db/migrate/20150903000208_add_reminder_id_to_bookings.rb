class AddReminderIdToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :reminder_group, :integer
  end
end
