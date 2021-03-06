class PayedBooking < ActiveRecord::Base
	belongs_to :punto_pagos_confirmation
	belongs_to :payment_account

	has_many :bookings
	has_many :sendings, class_name: 'Email::Sending', as: :sendable

	WORKER = 'PayedBookingEmailWorker'

	#after_create :send_confirmation

	# def send_confirmation
	# 	#Enviar resúmenes de reservas
	# 	if self.bookings.count >1
	# 		Booking.send_multiple_booking_mail(self.bookings.first.location_id, self.bookings.count)
	# 	else
	# 		BookingMailer.book_service_mail(self.bookings.first)
	# 	end
	# 	#Enviar comprobantes de pago
	# 	BookingMailer.book_payment_mail(self)
	# 	BookingMailer.book_payment_company_mail(self)
	# end


	def self.to_csv(type, p_start_date, p_end_date)

		CSV.generate do |csv|

	        start_date = DateTime.new(1990,1,1,0,0,0)
	    	end_date = DateTime.now

	    	canceled = false
	    	cancel_complete = false
	    	transfer_complete = false

	      	if(p_start_date != "")
	      		start_date = DateTime.parse(p_start_date)
	      	end
	      	if(p_end_date != "")
	      		end_date = DateTime.parse(p_end_date)
	      	end


	      	if type == "admin_canceled_pending"
	      		canceled = true
	      		cancel_complete = false
	      		transfer_complete = false
	      	elsif type == "admin_canceled_transfered"
	      		canceled = true
	      		cancel_complete = true
	      		transfer_complete = false
	      	elsif type == "company_pending"
	      		canceled = false
	      		cancel_complete = false
	      		transfer_complete = false
	      	elsif type == "company_transfered" || type == "admin_transfered_bookings"
	      		canceled = false
	      		cancel_complete = false
	      		transfer_complete = true
	      	end

	      	#Distintos headers dependiendo de si está cancelado o es vista de compañía
	      	if canceled
	      		header = ["Id", "Cliente", "Email", "Empresa", "Servicio", "Monto", "Orden de compra", "Código de autorización", "Fecha"]
	      		csv << header
	      	else
	      		if type != "admin_transfered_bookings"
	      			header = ["Id", "Cliente", "Local", "Servicio", "Monto", "Orden de compra", "Código de autorización", "Fecha"]
	      			csv << header
		      	else
		      		header = ["Id", "Payment ID", "Empresa", "Cliente", "Monto", "Orden de compra", "Código de autorización", "Fecha"]
	      			csv << header
		      	end
	      	end

		    arr = PayedBooking.where("canceled = ? and cancel_complete = ? and transfer_complete = ? and created_at BETWEEN ? AND ?", canceled, cancel_complete, transfer_complete, start_date, end_date)

	        arr.each do |payed_booking|

	        	if type != "admin_transfered_bookings"
		        	row_array = Array.new

		        	row_array << payed_booking.id
		        	row_array << payed_booking.bookings.first.client.first_name + " " + payed_booking.bookings.first.client.last_name

		        	if canceled
		        		row_array << payed_booking.bookings.first.client.email
		        		row_array << payed_booking.bookings.first.location.company.name
		        	else
		        		row_array << payed_booking.bookings.first.location.name
		        	end

		        	services_str = ""
		        	payed_booking.bookings.each do |booking|
		        		services_str = services_str + " - " + booking.service.name
		        	end
		        	services_str = services_str[0, services_str.length-3]
		        	row_array << services_str
		        	row_array << payed_booking.punto_pagos_confirmation.amount
		        	row_array << payed_booking.punto_pagos_confirmation.operation_number
		        	row_array << payed_booking.punto_pagos_confirmation.authorization_code
		        	row_array << payed_booking.punto_pagos_confirmation.approvement_date

		        	csv << row_array
		        else
		        	row_array = Array.new

		        	row_array << payed_booking.id
		        	row_array << payed_booking.payment_account.id
		        	row_array << payed_booking.bookings.first.location.company.name
		        	row_array << payed_booking.bookings.first.client.first_name + " " + payed_booking.bookings.first.client.last_name
		        	row_array << payed_booking.punto_pagos_confirmation.amount
		        	row_array << payed_booking.punto_pagos_confirmation.operation_number
		        	row_array << payed_booking.punto_pagos_confirmation.authorization_code
		        	row_array << payed_booking.punto_pagos_confirmation.approvement_date

		        	csv << row_array
		        end
	        end
	    end

	end

  def payment_email
    sendings.build(method: 'payment_booking').save
  end

  def cancel_payment_email
    sendings.build(method: 'cancel_payment_booking').save
  end

end
