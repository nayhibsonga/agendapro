class PayedBookingsController < ApplicationController

	require 'csv'

	before_action :verify_is_admin, :only => [:get_by_user]
  	before_action :verify_is_super_admin, :only => [:index, :show, :create_csv]
  	skip_before_action :verify_authenticity_token
  	layout "admin"
  	load_and_authorize_resource

  	def index
  		

  		#Organizar por compañía para hacer una sola transferencia:

  		#payment_account name:string rut:string number:string amount:float bank_code:integer type:integer currency:integer origin:integer destiny:integer

  		#Pagos pendiente de payed_bookings sumados por empresa.
  		@companies_pending_payment = Array.new
  		Company.all.each do |company|
  			payment_account = PaymentAccount.new
  		 	company.locations.each do |loc|
  		 		loc.bookings.each do |booking|
  		 			if(!booking.payed_booking.nil?)

  		 				if payment_account.name.nil?
  		 					payment_account.name = company.account_name
  		 					payment_account.rut = company.company_rut
  		 					payment_account.number = company.account_number
  		 					payment_account.amount = booking.payed_booking.punto_pagos_confirmation.amount
  		 					payment_account.bank_code = company.bank.code
  		 					payment_account.account_type = company.account_type
  		 				else
  		 					payment_account.amount = payment_account.amount + booking.payed_booking.punto_pagos_confirmation.amount
  		 				end

  		 			end
  		 		end
  		 	end
  		 	if !payment_account.name.nil?
  		 		payment_account.save
  		 		@companies_pending_payment << payment_account
  		 	end
  		end

  		@transfered_bookings = PayedBooking.where(:transfer_complete => true, :canceled => false).order('updated_at DESC').limit(10)

		@pending_bookings = PayedBooking.where(:transfer_complete => false, :canceled => false).order('updated_at DESC')
		@pending_canceled_bookings = PayedBooking.where(:transfer_complete => false, :canceled => true, :cancel_complete => false).order('updated_at DESC')

		@cancel_complete = PayedBooking.where(:cancel_complete => true).order('updated_at DESC')

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
