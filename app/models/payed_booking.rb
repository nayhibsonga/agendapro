class PayedBooking < ActiveRecord::Base
	
	belongs_to :booking
	belongs_to :punto_pagos_confirmation

	after_create :send_confirmation

	def send_confirmation

		#Enviar comprobantes de pago
		BookingMailer.book_payment_mail(self)
		BookingMailer.book_payment_company_mail(self)
		
	end

end
