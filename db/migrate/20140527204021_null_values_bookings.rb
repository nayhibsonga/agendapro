class NullValuesBookings < ActiveRecord::Migration
  def change
  	change_column :bookings, :first_name, :string, :null => true
  	change_column :bookings, :last_name, :string, :null => true
  	change_column :bookings, :email, :string, :null => true
  	change_column :bookings, :phone, :string, :null => true
  end
end
