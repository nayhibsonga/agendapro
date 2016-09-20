class AddPayedStateToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :payed_state, :boolean, default: false
  end
end
