class AddUserToBookingHistory < ActiveRecord::Migration
  def change
    add_reference :booking_histories, :user, index: true
  end
end
