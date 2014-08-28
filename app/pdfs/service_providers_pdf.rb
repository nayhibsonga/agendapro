class ServiceProvidersPdf < Prawn::Document
	def initialize(service_provider)
		super()
		@service_provider = service_provider
		header
		text_content
		table_content
	end
	
	def header
		y_position = cursor
		bounding_box([0, y_position], width: 260, height: 70) do
			if @service_provider.company.logo.to_s != ""
				image "#{Rails.root}/public"+@service_provider.company.logo.to_s, width: 70, height: 70
			else
				image "#{Rails.root}/app/assets/images/logos/logo_mail.png", width: 100, height: 37
			end
		end
		bounding_box([480, y_position], width: 260, height: 70) do
			text  I18n.l DateTime.now.to_date
		end
	end

	def text_content
		move_down 20

		text @service_provider.public_name, size: 15, style: :bold
		text @service_provider.notification_email, size: 12, style: :bold
	end

	def table_content
		move_down 20

		table(provider_hours, header: true, position: :center, row_colors: ['E6E3CF', 'FFFFFF'], width: 540) do
			cells.borders = []

			row(0).borders = [:bottom]
			row(0).font_style = :bold
			row(0).text_color = 'FFFFFF'
			row(0).background_color = '1E8584'

			columns(0..2).borders = [:right]
			row(0).columns(0..2).borders = [:bottom, :right]
		end
	end

	def provider_hours
		now = DateTime.now
		block_length = 30 * 60

		provider_times = @service_provider.provider_times.where(day_id: now.cwday)
		bookings = Booking.where(service_provider: @service_provider, status: Status.find_by(name: ['Reservado', 'Confirmado','Pagado'])).order(:start)

		table_rows = []

		provider_times.each do |provider_time|
			provider_open = provider_time.open
			while (provider_open <=> provider_time.close) < 0 do
				table_row = [provider_open.strftime('%R'), nil, nil, nil]

				provider_open += block_length
				block_open = DateTime.new(now.year, now.mon, now.mday, provider_open.hour, provider_open.min)
				block_close = DateTime.new(now.year, now.mon, now.mday, provider_open.hour, provider_open.min)

				bookings.each do |book|
					book_start = DateTime.parse(book.start.to_s)
              		book_end = DateTime.parse(book.end.to_s)

					if (block_close - book_start) * (book_end - block_open) > 0
						service_name = book.service.name
						client_name = ''
						client_phone = ''
						if !book.client_id.blank?
							client_name = book.client.first_name + ' ' + book.client.last_name
							client_phone = book.client.phone
						end

						table_row << service_name
						table_row << client_name
						table_row << client_phone
						table_row.compact!

						table_rows.append(table_row)
						# table_row = ['', nil, nil, nil]
					end

				end
				table_rows.append(table_row)
			end
		end

		table_header = [['Hora', 'Servicio', 'Cliente', 'Teléfono']]

		return table_header + table_rows
	end

end