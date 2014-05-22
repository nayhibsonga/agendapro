class AddNameToBooking < ActiveRecord::Migration
  def up
    add_column :bookings, :client_name, :string 
    Booking.all.order(:updated_at).each do |booking|
      puts booking.id
      booking.update_attributes! :client_name => booking.first_name + " " + booking.last_name
    end
    remove_column :bookings, :first_name
    remove_column :bookings, :last_name  
  end
  def down
    add_column :first_name, :last_name
    Booking.all.each do |booking|
      booking.update_attributes! :first_name => booking.client_name.match(/\w+/)[0]
      booking.update_attributes! :last_name => booking.client_name.match(/\w+/)[1]
    end
    remove_column :client_name
  end
end
