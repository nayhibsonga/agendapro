class AddPayedToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :payed, :boolean
  end
end
