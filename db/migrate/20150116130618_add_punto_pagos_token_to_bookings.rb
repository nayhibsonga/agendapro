class AddPuntoPagosTokenToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :token, :string, default: ""
  end
end
