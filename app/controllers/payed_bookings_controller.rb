class PayedBookingsController < ApplicationController

	require 'csv'

	before_action :verify_is_admin, :only => [:get_by_user]
  	before_action :verify_is_super_admin, :only => [:index, :show, :create_csv]
  	skip_before_action :verify_authenticity_token
  	layout "admin"
  	load_and_authorize_resource

  	def index
  		
  		@transfered_bookings = PayedBooking.where(:transfer_complete => true, :canceled => false).order('updated_at DESC').limit(10)
  		@transfered_canceled_bookings = PayedBooking.where(:transfer_complete => true, :canceled => true).order('updated_at DESC')

		@pending_bookings = PayedBooking.where(:transfer_complete => false, :canceled => false).order('updated_at DESC')
		@pending_canceled_bookings = PayedBooking.where(:transfer_complete => false, :canceled => true).order('updated_at DESC')

  	end

	def show
		@transfered_bookings = PayedBooking.where(:transfer_complete => true)
		@pending_bookings = PayedBooking.where(:transfer_complete => false)
	end

	def create_csv
	
		respond_to do |format|
	      format.html
	      format.csv { render text: PayedBooking.to_csv(params[:type], params[:start_date], params[:end_date]), :filename => "online_payments.csv" }
	    end		

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
