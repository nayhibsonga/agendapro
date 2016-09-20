class AddDealToBooking < ActiveRecord::Migration
  def change
    add_reference :bookings, :deal, index: true
  end
end
