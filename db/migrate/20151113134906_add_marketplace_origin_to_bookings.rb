class AddMarketplaceOriginToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :marketplace_origin, :boolean, default: false
  end
end
