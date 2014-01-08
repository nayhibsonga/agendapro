class AddDetailsToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :first_name, :string, :null => false
    add_column :bookings, :last_name, :string, :null => false
    add_column :bookings, :mail, :string, :null => false
    add_column :bookings, :phone, :string, :null => false
  end
end
