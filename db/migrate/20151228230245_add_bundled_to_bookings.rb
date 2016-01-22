class AddBundledToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :bundled, :boolean, default: false
  end
end
