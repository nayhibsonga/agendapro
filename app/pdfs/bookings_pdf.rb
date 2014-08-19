class BookingsPdf < Prawn::Document
	def initialize(booking)
		super()
		@booking = booking
		header
		text_content
		table_content
		notes_content
	end
	
	def header
		y_position = cursor
		bounding_box([0, y_position], width: 260, height: 40) do
			image "#{Rails.root}/app/assets/images/logos/logo_mail.png", width: 100, height: 37
		end
		bounding_box([380, y_position], width: 260, height: 40) do
			text DateTime.now.to_date.strftime('%d de %B de %Y')
		end
	end

	def text_content
		move_down 20

		text @booking.service.name, size: 15, style: :bold, :align => :center
	end

	def table_content
		move_down 20
		y_position = cursor

		bounding_box([0, y_position], width: 260) do
			text 'Reserva', size: 12, style: :bold
			table(booking_data, position: :center, row_colors: ['DFD1A7', 'FFFFFF'], width: 260)
		end

		bounding_box([280, y_position], width: 260) do
			text 'Cliente', size: 12, style: :bold
			table(client_data, position: :center, row_colors: ['DFD1A7', 'FFFFFF'], width: 260)
		end
	end

	def booking_data
		table_rows = []

		table_rows << ['¿Que?', @booking.service.name]
		table_rows << ['¿Cuando?', @booking.start.strftime('%d de %B de %Y a las %H:%M')]
		if !@booking.service.outcall
			table_rows << ['¿Donde?', @booking.location.address + ', ' + @booking.location.district.name]
		end
		table_rows << ['¿Con Quien?', @booking.service_provider.public_name]
		if @booking.service.show_price
			table_rows << ['¿Precio?', @booking.service.price]
		end
		return table_rows
	end

	def client_data
		table_rows = []

		table_rows << ['Nombre', @booking.client.first_name + ' ' + @booking.client.last_name]
		if !@booking.client.email.blank?
			table_rows << ['Email', @booking.client.email]
		end
		if !@booking.client.phone
			table_rows << ['Teléfono', @booking.client.phone]
		end

		return table_rows
	end

	def notes_content
		move_down 120

		text 'Notas', size: 15, style: :bold
		if !@booking.notes.blank?
			text @booking.notes
		end
		if !@booking.company_comment.blank?
			text 'Comentario Interno', size: 12, style: :bold
			text @booking.company_comment
		end
	end

end