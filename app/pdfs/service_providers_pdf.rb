class ServiceProvidersPdf < Prawn::Document
	def initialize(service_provider, provider_date, location_id, current_ability)
		font_families.update(
			"Roboto" => {
				normal: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Light.ttf')}", font: 'Roboto Condensed Light'},
				bold: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Bold.ttf')}", font: 'Roboto Condensed Bold'}
			}
		)

		if service_provider != 0
			super()
			font 'Roboto'

			@service_provider = ServiceProvider.find(service_provider)
			@provider_date = provider_date
			header
			text_content
			table_content
		else
			super()
			font 'Roboto'

			@provider_date = provider_date
			@providers = ServiceProvider.where(location_id: location_id, active: true).accessible_by(current_ability).order(:order)
			@providers.each do |provider|
				@service_provider = provider
				header
				text_content
				table_content
				if @service_provider != @providers.last
					start_new_page
				end
			end
		end
	end

	def header
		y_position = cursor
		bounding_box([0, y_position], width: 260, height: 50) do
			if @service_provider.company.logo.to_s != ""
				image "#{Rails.root}/public"+@service_provider.company.logo.to_s, width: 50, height: 50
			else
				image "#{Rails.root}/app/assets/images/logos/logodoble2.png", width: 100, height: 37
			end
		end
		bounding_box([480, y_position], width: 260, height: 50) do
			text @provider_date.strftime('%d/%m/%Y'), color: '4a4644', font: "Roboto"
		end
	end

	def text_content
		text @service_provider.public_name, size: 11, color: '4a4644', style: :bold
	end

	def table_content
		move_down 10

		table(provider_hours, header: true, position: :center, row_colors: ['fbe09c', 'FFFFFF'], width: 540, :column_widths => [60,190,190,100]) do
			cells.borders = []

			columns(0..2).text_color = '4a4644'
			columns(0..2).borders = [:right]
			columns(0..2).border_color = '4a4644'

			row(0).font_style = :bold
			row(0).text_color = 'FFFFFF'
			row(0).background_color = '22c488'

			cells.row(0).align = :center
			cells.column(0).align = :center
			cells.style.size = 9
		end
	end

	def provider_hours
		now = @provider_date
		block_length = @service_provider.block_length * 60
		table_rows = []

		provider_times = @service_provider.provider_times.where(day_id: now.cwday).order(:open)

		if provider_times.length > 0

			open_provider_time = provider_times.first.open
			close_provider_time = provider_times.last.close

			provider_open = provider_times.first.open
			while (provider_open <=> close_provider_time) < 0 do
				provider_close = provider_open + block_length

				table_row = [provider_open.strftime('%R'), nil, nil, nil]
				last_row = table_rows.length - 1

				block_open = DateTime.new(now.year, now.mon, now.mday, provider_open.hour, provider_open.min)
				block_close = DateTime.new(now.year, now.mon, now.mday, provider_close.hour, provider_close.min)

				service_name = 'Descanso por Horario'
				client_name = '...'
				client_phone = '...'

				in_provider_time = false
				provider_times.each do |provider_time|
					if (provider_time.open - provider_close)*(provider_open - provider_time.close) > 0
						in_provider_time = true
						service_name = ''
						client_name = ''
						client_phone = ''
						break
					end
				end
				in_provider_booking = false
		        # if in_provider_time
		          Booking.where(service_provider: @service_provider, status_id: Status.where(name: ['Reservado', 'Confirmado','Pagado','Asiste']).pluck(:id)).where('bookings.start >= ? AND bookings.start < ?', block_open, block_close).order(:start).each do |booking|
		              in_provider_booking = true
		              table_rows.append([booking.start.strftime('%R'), booking.service.name, booking.client.first_name + ' ' + booking.client.last_name, booking.client.phone])
		          end
		        # end
		        in_provider_break = false
		        if in_provider_time && !in_provider_booking
		          ProviderBreak.where(service_provider: @service_provider, start: now.beginning_of_day..now.end_of_day).each do |provider_break|
		            if (provider_break.start.to_datetime - block_close)*(block_open - provider_break.end.to_datetime) > 0
		              in_provider_booking = true
		              service_name = "Bloqueo: "+provider_break.name
		              client_name = '...'
		              client_phone = '...'
		              break
		            end
		          end
		        end

		        if in_provider_time

		          if last_row >= 0
		            while table_rows[last_row][1] == 'Continuación...'  do
		              # Subir un nivel para ver si es el mismo servicio o no
		                last_row -=1
		            end

		            # if in_provider_time
		              Booking.where(service_provider: @service_provider, status_id: Status.where(name: ['Reservado', 'Confirmado','Pagado','Asiste']).pluck(:id), start: now.beginning_of_day..now.end_of_day).order(:start).each do |booking|
		                if (booking.start.to_datetime - block_close)*(block_open - booking.end.to_datetime) > 0
		                  in_provider_booking = true
		                  service_name = booking.service.name
		                  client_name = booking.client.first_name + ' ' + booking.client.last_name
		                  client_phone = booking.client.phone
		                  break
		                end
		              end
		            # end

		            if (service_name != '') && (service_name == table_rows[last_row][1]) && (client_name == (table_rows[last_row][2]))

		              service_name = 'Continuación...'
		              client_name = '...'
		              client_phone = '...'

		              table_rows.append([provider_open.strftime('%R'), 'Continuación...', '...', '...'])
		            end
		          end
		        end

		        if !in_provider_booking
		          table_row << service_name
		          table_row << client_name
		          table_row << client_phone
		          table_row.compact!

		          table_rows.append(table_row)
		        end

				provider_open += block_length
			end
		end

		table_header = [['Hora', 'Servicio', 'Cliente', 'Teléfono']]

		return table_header + table_rows

	end

end
