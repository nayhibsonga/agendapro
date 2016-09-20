class AddSendMailToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :send_mail, :boolean, :default => true
  end
end
