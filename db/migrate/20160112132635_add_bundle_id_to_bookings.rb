class AddBundleIdToBookings < ActiveRecord::Migration
  def change
    add_reference :bookings, :bundle, index: true
  end
end
