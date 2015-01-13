class PaymentAccount < ActiveRecord::Base
	has_many :payed_bookings
	belongs_to :company


	def self.to_csv(type, p_start_date, p_end_date)
		CSV.generate do |csv|

			#head_array = ["ID", "Empresa", "Banco", "Cuenta Corriente", "Rut", "Email", "Cliente", "Monto recibido", "Orden de compra", "Código de autorización", "Fecha"]

	        #head_array = self.column_names + Booking.column_names + PuntoPagosConfirmation.column_names
	        #head_array << Booking.column_names
	        #head_array << PuntoPagosConfirmation.column_names

	        #csv << head_array
	      	
	        start_date = DateTime.new(1990,1,1,0,0,0)
	    	end_date = DateTime.now
	    	transfer = false

	      	if(p_start_date != "")
	      		start_date = DateTime.parse(p_start_date)
	      	end
	      	if(p_end_date != "")
	      		end_date = DateTime.parse(p_end_date)
	      	end
	      	if(type != "pending")
	      		transfer = true
	      	end

	      	

		    arr = PaymentAccount.where("status = ? and created_at BETWEEN ? AND ?", false, start_date, end_date)

	        arr.each do |payment_account|
	        	row_array = Array.new
	        	row_array << payment_account.name.gsub(/-/,'')
	        	row_array << payment_account.rut.gsub(/[\s.-]/,'')
	        	row_array << payment_account.number.gsub(/[\s.-]/,'')
	        	row_array << payment_account.amount.to_s.gsub(/[\s.-]/,'')
	        	row_array << payment_account.bank_code
	        	row_array << payment_account.account_type
	        	row_array << 0
	        	row_array << 1
	        	row_array << 1
	        	factura = payment_account.rut.gsub(/[\s.-]/,'').to_s + payment_account.bank_code.to_s + payment_account.account_type.to_s
	        	row_array << factura
	        	csv << row_array
	        end

	    end
	end


end
