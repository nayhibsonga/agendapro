class PayedBooking < ActiveRecord::Base
	
	belongs_to :booking
	belongs_to :punto_pagos_confirmation

	#after_create :send_confirmation

	def send_confirmation
		#Enviar comprobantes de pago
		BookingMailer.book_payment_mail(self)
		BookingMailer.book_payment_company_mail(self)
	end

	def self.to_csv(type, p_start_date, p_end_date)
		CSV.generate do |csv|

			head_array = ["ID", "Empresa", "Banco", "Cuenta Corriente", "Rut", "Email", "Cliente", "Monto recibido", "Orden de compra", "Código de autorización", "Fecha"]

	        #head_array = self.column_names + Booking.column_names + PuntoPagosConfirmation.column_names
	        #head_array << Booking.column_names
	        #head_array << PuntoPagosConfirmation.column_names

	        csv << head_array
	      	
	        start_date = DateTime.new(1990,1,1,0,0,0)
	    	end_date = DateTime.now
	    	transfer = false

	      	if(p_start_date != "")
	      		start_date = DateTime.parse(params[:start_date])
	      	end
	      	if(p_end_date != "")
	      		end_date = DateTime.parse(params[:end_date])
	      	end
	      	if(type != "pending")
	      		transfer = true
	      	end

		    arr = PayedBooking.where("transfer_complete = ? and created_at BETWEEN ? AND ?", transfer, start_date, end_date)

	        arr.each do |payed_booking|
	        	row_array = Array.new
	        	row_array << payed_booking.id
	        	row_array << payed_booking.booking.location.company.name
	        	row_array << payed_booking.booking.location.company.bank
	        	row_array << payed_booking.booking.location.company.account_number
	        	row_array << payed_booking.booking.location.company.company_rut
	        	owner = User.find_by_company_id(payed_booking.booking.location.company.id)
	        	row_array << owner.email
	        	row_array << payed_booking.booking.client.first_name + " " + payed_booking.booking.client.last_name
	        	row_array << payed_booking.punto_pagos_confirmation.amount
	        	row_array << payed_booking.punto_pagos_confirmation.operation_number
	        	row_array << payed_booking.punto_pagos_confirmation.authorization_code
	        	row_array << payed_booking.punto_pagos_confirmation.approvement_date
	        	csv << row_array
	        end

	    end
	end

end
