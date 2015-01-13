class PayedBookingsController < ApplicationController

	require 'csv'

	before_action :verify_is_admin, :only => [:get_by_user]
  	before_action :verify_is_super_admin, :only => [:index, :show, :create_csv, :mark_as_payed, :mark_several_as_payed]
  	#before_action :authenticate_user!
  	skip_before_action :verify_authenticity_token
  	layout "admin"
  	load_and_authorize_resource

  	def index
  		

  		#Organizar por compañía para hacer una sola transferencia:
  		#Pagos pendiente de payed_bookings sumados por empresa.
  		@companies_pending_payment = Array.new

  		Company.all.each do |company|


  			payment_account = PaymentAccount.new
  			if(PaymentAccount.where(:company_id => company.id, :status => false).count > 0)
  				payment_account = PaymentAccount.where(:company_id => company.id, :status => false).first  			
	  		end
	  		payment_account.amount = 0 #Lo reseteamos y sumamos de nuevo por si hubiera un nuevo payed_booking

  		 	company.locations.each do |loc|
  		 		loc.bookings.each do |booking|

  		 			if(!booking.payed_booking.nil?)

  		 				if payment_account.company_id.nil?
  		 					payment_account.name = company.account_name
  		 					payment_account.rut = company.company_rut
  		 					payment_account.number = company.account_number
  		 					payment_account.company = company
  		 					payment_account.bank_code = company.bank.code
  		 					payment_account.account_type = company.account_type
  		 				end
  		 				
  		 				payment_account.amount = payment_account.amount + booking.payed_booking.punto_pagos_confirmation.amount

  		 				if(booking.payed_booking.payment_account.nil?)
  		 					booking.payed_booking.payment_account = payment_account
  		 					booking.payed_booking.save
  		 				end
  		 				
  		 			end
  		 		end
  		 	end

  		 	if !payment_account.amount.nil? and payment_account.amount > 0
  		 		payment_account.save
  		 		@companies_pending_payment << payment_account
  		 	else
  		 		#payment_account.destroy
  		 	end

  		end

  		@transfered_bookings = PayedBooking.where(:transfer_complete => true, :canceled => false).order('updated_at DESC').limit(10)

		#@pending_bookings = PayedBooking.where(:transfer_complete => false, :canceled => false).order('updated_at DESC')
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
	      format.csv { render text: PaymentAccount.to_csv(params[:type], params[:start_date], params[:end_date]), :filename => "online_payments.csv" }
	    end		

	end

	def mark_as_payed

		@response = Hash.new
		@response['status'] = 'error'
		@response['error'] = ''

		@payment_account = PaymentAccount.find(params[:id])
		@payment_account.status = true
		@payment_account.payed_bookings.each do |payed_booking|
			payed_booking.transfer_complete = true
			payed_booking.booking.status = Status.where(:name => "Pagado")
			payed_booking.booking.save
			payed_booking.save
		end
		if @payment_account.save
			@response['status'] = 'ok'
		else
			@response['error'] = @payment_account.errors
		end

		redirect_to action: 'index' 

		# respond_to do |format|
		# 	format.json { render json: @response}
		# end

	end

	def mark_several_as_payed

		@response = Hash.new
		@response['status'] = 'error'
		@response['error'] = ''

		@payment_accounts = PaymentAccount.find(params[:ids])
		@payment_accounts.each do |payment_account|
			payment_account.status = true
			payment_account.payed_bookings.each do |payed_booking|
				payed_booking.transfer_complete = true
				payed_booking.booking.status = Status.where(:name => "Pagado")
				payed_booking.booking.save
				payed_booking.save
			end
			if payment_account.save
				@response['status'] = 'ok'
			else
				@response['error'] = payment_account.errors
			end
		end

		redirect_to action: 'index'
		# respond_to do |format|
		# 	format.json { render json: @response}
		# end

	end

	def get_by_user

		company = current_user.company
		bookings = company.locations.bookings

		@pending_payments = Array.new
		@transfered_payments = Array.new
		@payment_accounts = company.payment_accounts

		bookings.each do |booking|
			if !booking.payed_booking.nil?
				if booking.payed_booking.transfer_complete
					@transfered_payments << booking.payed_booking
				else
					@pending_payments << booking.payed_booking
				end
			end
		end
	end

	private

		def payed_booking_params
			params.require(:payed_booking).permit(:id)
		end

end
