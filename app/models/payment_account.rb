class PaymentAccount < ActiveRecord::Base
	has_many :payed_bookings
	belongs_to :company


	def self.to_csv(type, p_start_date, p_end_date)

		CSV.generate(col_sep: ';') do |csv|
	      	
	        start_date = DateTime.new(1990,1,1,0,0,0)
	    	end_date = DateTime.now
	    	status = false
	    	other_banks = false

	      	if(p_start_date != "")
	      		start_date = DateTime.parse(p_start_date)
	      	end
	      	if(p_end_date != "")
	      		end_date = DateTime.parse(p_end_date)
	      	end
	      	if(type == "admin_pending")
	      		status = false
	      	elsif type=="other_admin_pending"
	      		other_banks = true
	      		status = false
	      	elsif(type == "admin_transfered")
	      		status = true
	      		header = ["Nombre titular", "Rut titular", "Cuenta titular", "Monto", "Banco", "Tipo de cuenta", "Moneda", "Oficina origen", "Oficina destino", "N° Factura", "Fecha de pago"]
	      		csv << header
	      	end      	

	      	other_bank_code = Bank.find_by_name("Otro").code

	      	if !other_banks
		    	arr = PaymentAccount.where("status = ? and created_at BETWEEN ? AND ? AND bank_code <> ?", status, start_date, end_date, other_bank_code)
			else
				arr = PaymentAccount.where("status = ? and created_at BETWEEN ? AND ? AND bank_code = ?", status, start_date, end_date, other_bank_code)
			end

	        arr.each do |payment_account|
	        	row_array = Array.new
	        	row_array << payment_account.name.mb_chars.normalize(:kd).gsub(/[']/,'').gsub(/[^\x00-\x7F]/,'').upcase.lstrip.rstrip
	        	row_array << payment_account.rut.gsub(/[\s.-]/,'')
	        	row_array << payment_account.number.gsub(/[\s.-]/,'')
	        	row_array << payment_account.company_amount.round.to_s.gsub(/[\s.-]/,'')
	        	row_array << payment_account.bank_code
	        	row_array << payment_account.account_type
	        	row_array << 0
	        	row_array << 1
	        	row_array << 1
	        	factura = payment_account.rut.gsub(/[\s.-]/,'').to_s + payment_account.bank_code.to_s + payment_account.account_type.to_s
	        	row_array << factura
	        	row_array << payment_account.updated_at + eval(ENV["TIME_ZONE_OFFSET"])
	        	csv << row_array
	        end
	    end

	end


end
