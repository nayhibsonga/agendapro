class AddProviderLockToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :provider_lock, :boolean, default: false
  end
end
