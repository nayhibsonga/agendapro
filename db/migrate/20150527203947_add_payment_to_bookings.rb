class AddPaymentToBookings < ActiveRecord::Migration
  def change
    add_reference :bookings, :payment, index: true
  end
end
