class PayedBookingsController < ApplicationController

  def show
  	@transfered_bookings = Booking.where(:transfer_complete => true)
  	@pending_bookings = Booking.where(:transfer_complete => false)
  end

  def get_by_user
  	company = current_user.company
  	bookings = company.locations.bookings
  	@payed_bookings = Array.new
  	bookings.each do |booking|
  		if !booking.payed_booking.nil?
  			@payed_bookings << booking.payed_bookings
  		end
  	end
  end

end
