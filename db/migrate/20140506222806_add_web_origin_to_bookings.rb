class AddWebOriginToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :web_origin, :boolean, :default => false
  end
end
