class AddClientToPayments < ActiveRecord::Migration
  def change
    add_reference :payments, :location, index: true
    add_reference :payments, :client, index: true
    add_column :bookings, :discount, :float, default: 0.0
  end
end
