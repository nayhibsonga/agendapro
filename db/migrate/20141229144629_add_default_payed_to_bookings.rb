class AddDefaultPayedToBookings < ActiveRecord::Migration
  def change
  	change_column :bookings, :payed, :boolean, default: false
  end
end
