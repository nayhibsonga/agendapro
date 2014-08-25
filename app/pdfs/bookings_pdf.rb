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
		bounding_box([480, y_position], width: 260, height: 40) do
			text  I18n.l DateTime.now.to_date
		end
	end

	def text_content
		move_down 20

		text 'Reserva de ' + @booking.client.first_name + ' ' + @booking.client.last_name, size: 15, style: :bold, :align => :center
	end

	def table_content
		move_down 20
		
		text 'Resumen de la Reserva', size: 14, style: :bold
		table(booking_data, position: :center, row_colors: ['E6E3CF', 'FFFFFF'])

		move_down 20		
		text 'Datos del Cliente', size: 14, style: :bold
		table(client_data, position: :center, row_colors: ['E6E3CF', 'FFFFFF'])
	end

	def booking_data
		table_rows = []

		table_rows << ['Servicio', @booking.service.name]
		table_rows << ['Horario', I18n.l(@booking.start)]
		if !@booking.service.outcall
			table_rows << ['Lugar', @booking.location.address + ', ' + @booking.location.district.name]
		end
		table_rows << ['Prestador', @booking.service_provider.public_name]
		if @booking.service.show_price
			table_rows << ['Precio', @booking.service.price]
		end
		return table_rows
	end

	def client_data
		table_rows = []

		table_rows << ['Nombre', @booking.client.first_name + ' ' + @booking.client.last_name]
		table_rows << ['Email', @booking.client.email]
		table_rows << ['Teléfono', @booking.client.phone]

		return table_rows
	end

	def notes_content
		move_down 20
		text 'Notas', size: 14, style: :bold
		text @booking.notes
	end

end