class PayedBookingsController < ApplicationController

	before_action :verify_is_admin, :only => [:get_by_user]
  	before_action :verify_is_super_admin, :only => [:index, :show]

  	def index
  		@transfered_bookings = PayedBooking.where(:transfer_complete => true)
		@pending_bookings = PayedBooking.where(:transfer_complete => false)
  	end

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
