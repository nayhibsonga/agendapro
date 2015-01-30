class AddTokenToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :trx_id, :string, default: ""
  end
end
