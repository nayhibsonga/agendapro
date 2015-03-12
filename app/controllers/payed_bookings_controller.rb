class PayedBookingsController < ApplicationController

	require 'csv'

	before_action :verify_is_admin, :only => [:show, :edit, :create_company_csv]
  	before_action :verify_is_super_admin, :only => [:index, :create_csv, :mark_as_payed, :mark_several_as_payed, :mark_canceled_as_payed, :mark_several_canceled_as_payed]
  	#before_action :authenticate_user!
  	skip_before_action :verify_authenticity_token
  	layout "admin"
  	#load_and_authorize_resource

  	def index
  		

  		#Organizar por compañía para hacer una sola transferencia:
  		#Pagos pendiente de payed_bookings sumados por empresa.
  		@companies_pending_payment = Array.new

  		#Comisión que se le cobra a la empresa por el pago en línea
  		commission = NumericParameter.find_by_name("online_payment_commission").value
  		now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)

  		Company.all.each do |company|

  			c_user = User.find_by_company_id(company.id)
  			
  			if !c_user.nil? and c_user.role_id != Role.find_by_name("Super Admin")
  				cancel_max = 0
  				limit_date = now
  				if !company.company_setting.online_cancelation_policy.nil?
	  				cancel_max = company.company_setting.online_cancelation_policy.cancel_max
	  				if company.company_setting.online_cancelation_policy.cancelable
	  					limit_date = now-cancel_max.hours
	  				end
	  			end
	  			
	  			pending_count = PayedBooking.where(:transfer_complete => false, :canceled => false, :booking_id => Booking.where('"bookings".created_at < ?', limit_date).where(:location_id => Location.where(:company_id => company.id))).count
	  			if pending_count > 0
		  			payment_account = PaymentAccount.new
		  			if(PaymentAccount.where(:company_id => company.id, :status => false).count > 0)
		  				payment_account = PaymentAccount.where(:company_id => company.id, :status => false).first  			
			  		end

			  		#Lo reseteamos y sumamos de nuevo por si hubiera un nuevo payed_booking
			  		payment_account.amount = 0
			  		payment_account.company_amount = 0
			  		payment_account.gain_amount = 0
			  		

		  		 	company.locations.each do |loc|
		  		 		loc.bookings.each do |booking|

		  		 			if(!booking.payed_booking.nil? && booking.payed_booking.canceled == false)
		  		 				
		  		 				if payment_account.company_id.nil?
		  		 					payment_account.name = company.company_setting.account_name
		  		 					payment_account.rut = company.company_setting.company_rut
		  		 					payment_account.number = company.company_setting.account_number
		  		 					payment_account.company = company
		  		 					payment_account.bank_code = company.company_setting.bank.code
		  		 					payment_account.account_type = company.company_setting.account_type
		  		 				end
		  		 				
		  		 				payment_account.amount = payment_account.amount + booking.payed_booking.punto_pagos_confirmation.amount
		  		 				payment_account.company_amount = payment_account.amount*(100-commission)/100

		  		 				
		  		 				booking.payed_booking.payment_account = payment_account
		  		 				booking.payed_booking.save
			  		 			
		  		 			end
		  		 		end
		  		 	end

		  		 	payment_account.gain_amount = payment_account.amount-payment_account.company_amount

		  		 	if !payment_account.amount.nil? and payment_account.amount > 0
		  		 		payment_account.save
		  		 		@companies_pending_payment << payment_account
		  		 	else
		  		 		#payment_account.destroy
		  		 	end
	  		 	end
  		 	end

  		end

  		@transfered_payments = PaymentAccount.where(:status => true)

  		@transfered_bookings = PayedBooking.where(:transfer_complete => true, :canceled => false).order('updated_at DESC').limit(25)

		#@pending_bookings = PayedBooking.where(:transfer_complete => false, :canceled => false).order('updated_at DESC')
		@pending_canceled_bookings = PayedBooking.where(:transfer_complete => false, :canceled => true, :cancel_complete => false).order('updated_at DESC')

		@cancel_complete = PayedBooking.where(:cancel_complete => true).order('updated_at DESC')

  	end

	def create_csv
	
		#respond_to do |format|
	    #  format.html
	    #  format.csv { render text: PaymentAccount.to_csv(params[:type], params[:start_date], params[:end_date]), :filename => "online_payments.csv" }
	    #end
	    filename = params[:type]
	    start_date = DateTime.new(1990,1,1,0,0,0).to_date
	    end_date = DateTime.now.to_date

	    if params[:start_date] != ""
	    	start_date = params[:start_date]
	    else
	    	start_date = start_date.to_s
	    end
	    if params[:end_date] != ""
	    	end_date = params[:end_date]
	    else
	    	end_date = end_date.to_s
	    end

	    filename = filename + "_" + start_date + "_" + end_date + ".csv"

	    if params[:type] == "admin_pending" || params[:type] == "admin_transfered"
	    	send_data PaymentAccount.to_csv(params[:type], params[:start_date], params[:end_date]), filename: filename
	    else
	    	send_data PayedBooking.to_csv(params[:type], params[:start_date], params[:end_date]), filename: filename
	    end
	end

	def create_company_csv
	
		#respond_to do |format|
	    #  format.html
	    #  format.csv { render text: PaymentAccount.to_csv(params[:type], params[:start_date], params[:end_date]), :filename => "online_payments.csv" }
	    #end
	    filename = params[:type]
	    start_date = DateTime.new(1990,1,1,0,0,0).to_date
	    end_date = DateTime.now.to_date

	    if params[:start_date] != ""
	    	start_date = params[:start_date]
	    else
	    	start_date = start_date.to_s
	    end
	    if params[:end_date] != ""
	    	end_date = params[:end_date]
	    else
	    	end_date = end_date.to_s
	    end

	    filename = filename + "_" + start_date + "_" + end_date + ".csv"

	    send_data PayedBooking.to_csv(params[:type], params[:start_date], params[:end_date]), filename: filename

	end

	def mark_as_payed

		@response = Hash.new
		@response['status'] = 'error'
		@response['error'] = ''

		@payment_account = PaymentAccount.find(params[:id])
		@payment_account.status = true
		@payment_account.payed_bookings.each do |payed_booking|
			payed_booking.transfer_complete = true
			payed_booking.booking.status_id = Status.find_by_name("Pagado").id
			payed_booking.booking.save
			payed_booking.save
		end
		if @payment_account.save
			@response['status'] = 'ok'
			redirect_to action: 'index'
			return
		else
			@response['error'] = @payment_account.errors
			redirect_to "/403"
			return
		end


	end

	def mark_several_as_payed

		@response = Hash.new
		@response['status'] = 'error'
		@response['error'] = ''

		#ids = Array.new
		#params[:ids].each do |id|
		#	if !id.nil? && !id==""
		#		ids << id
		#	end
		#end

		@payment_accounts = PaymentAccount.find(params[:ids])
		@payment_accounts.each do |payment_account|
			payment_account.status = true
			payment_account.payed_bookings.each do |payed_booking|
				payed_booking.transfer_complete = true
				payed_booking.booking.status_id = Status.find_by_name("Pagado").id
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

	end


	def unmark_as_payed

		@response = Hash.new
		@response['status'] = 'error'
		@response['error'] = ''

		@payment_account = PaymentAccount.find(params[:id])
		@payment_account.status = false
		@payment_account.payed_bookings.each do |payed_booking|
			payed_booking.transfer_complete = false
			payed_booking.booking.status_id = Status.find_by_name("Pagado").id
			payed_booking.booking.save
			payed_booking.save
		end
		if @payment_account.save
			@response['status'] = 'ok'
			redirect_to action: 'index'
			return
		else
			@response['error'] = @payment_account.errors
			redirect_to "/403"
			return
		end

	end

	def unmark_several_as_payed

		@response = Hash.new
		@response['status'] = 'error'
		@response['error'] = ''

		@payment_accounts = PaymentAccount.find(params[:ids])
		@payment_accounts.each do |payment_account|
			payment_account.status = false
			payment_account.payed_bookings.each do |payed_booking|
				payed_booking.transfer_complete = false
				payed_booking.booking.status_id = Status.find_by_name("Pagado").id
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
		return
	end


	def mark_canceled_as_payed

		payed_booking = PayedBooking.find(params[:id])
		payed_booking.cancel_complete = true
		if payed_booking.save
			redirect_to action: 'index'
			return
		else
			redirect_to "/403"
			return
		end
	end

	def mark_several_canceled_as_payed
		payed_bookings = PayedBooking.find(params[:ids])
		payed_bookings.each do |payed_booking|
			payed_booking.cancel_complete = true
			payed_booking.save
		end
		redirect_to action: 'index'
		return
	end

	def unmark_canceled_as_payed

		payed_booking = PayedBooking.find(params[:id])
		payed_booking.cancel_complete = false
		if payed_booking.save
			redirect_to action: 'index'
			return
		else
			redirect_to "/403"
			return
		end
	end

	def unmark_several_canceled_as_payed

		payed_bookings = PayedBooking.find(params[:ids])
		payed_bookings.each do |payed_booking|
			payed_booking.cancel_complete = false
			payed_booking.save
		end
		redirect_to action: 'index'
		return

	end

	def show

		company = current_user.company
		bookings = Booking.where(:location_id => Location.where(:company_id => company.id)).order('created_at desc')

		@pending_payments = Array.new
		@transfered_payments = Array.new
		@payment_accounts = company.payment_accounts

		bookings.each do |booking|
			if !booking.payed_booking.nil? && !booking.payed_booking.canceled
				if booking.payed_booking.transfer_complete
					@transfered_payments << booking.payed_booking
				else
					@pending_payments << booking.payed_booking
				end
			end
		end
	end

	def edit
		@payed_booking = PayedBooking.find(params[:id])
	end

	def update
		@payed_booking = PayedBooking.find(params[:id])
		@payed_booking.booking.status_id = Status.find(params[:status_id]).id
		if @payed_booking.booking.save
			redirect_to action: 'edit', id: @payed_booking.id, notice: 'Se ha editado correctamente.'
		else
			redirect_to action: 'edit', id: @payed_booking.id, alert: 'Ha ocurrido un error en la edición.'
		end
	end

	private

		def payed_booking_params
			params.require(:payed_booking).permit(:id)
		end

end
