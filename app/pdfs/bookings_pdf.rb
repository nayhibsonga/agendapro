class BookingsPdf < Prawn::Document
	def initialize(booking)
		super()
		@booking = booking
		header
		text_content
		# table_content
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
		y_position = cursor - 50

		bounding_box([0, y_position], width: 260, height: 300) do
			text @booking.first_name + ' ' + @booking.last_name, size: 15, style: :bold
			text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse interdum semper placerat. Aenean mattis fringilla risus ut fermentum. Fusce posuere dictum venenatis. Aliquam id tincidunt ante, eu pretium eros. Sed eget risus a nisl aliquet scelerisque sit amet id nisi. Praesent porta molestie ipsum, ac commodo erat hendrerit nec. Nullam interdum ipsum a quam euismod, at consequat libero bibendum. Nam at nulla fermentum, congue lectus ut, pulvinar nisl. Curabitur consectetur quis libero id laoreet. Fusce dictum metus et orci pretium, vel imperdiet est viverra. Morbi vitae libero in tortor mattis commodo. Ut sodales libero erat, at gravida enim rhoncus ut.'
		end
		bounding_box([280, y_position], width: 260, height: 300) do
			text @booking.company.name, size: 15, style: :bold
			text @booking.company.web_address, style: :bold
			text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse interdum semper placerat. Aenean mattis fringilla risus ut fermentum. Fusce posuere dictum venenatis. Aliquam id tincidunt ante, eu pretium eros. Sed eget risus a nisl aliquet scelerisque sit amet id nisi. Praesent porta molestie ipsum, ac commodo erat hendrerit nec. Nullam interdum ipsum a quam euismod, at consequat libero bibendum. Nam at nulla fermentum, congue lectus ut, pulvinar nisl. Curabitur consectetur quis libero id laoreet. Fusce dictum metus et orci pretium, vel imperdiet est viverra. Morbi vitae libero in tortor mattis commodo. Ut sodales libero erat, at gravida enim rhoncus ut.'
		end
	end

end