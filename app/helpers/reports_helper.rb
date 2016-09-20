module ReportsHelper

	def bookings_count_by_status(from, to, option, location_ids, status_name)

		status = Status.find_by_name(status_name)
		counted = 0
		total = 0
		percent = 0

		if option.to_i == 0
			bookings = Booking.where(created_at: from..to, location_id: location_ids).where('is_session = false or (is_session = true and is_session_booked = true)')
			status_bookings = bookings.where(status_id: status.id)
			if bookings.count > 0
				counted = status_bookings.count
				total = bookings.count
				percent = ((counted.to_f / total.to_f) * 100).round(0)
			end
		else
			bookings = Booking.where(start: from..to, location_id: location_ids).where('is_session = false or (is_session = true and is_session_booked = true)')
			status_bookings = bookings.where(status_id: status.id)
			if bookings.count > 0
				counted = status_bookings.count
				total = bookings.count
				percent = ((counted.to_f / total.to_f) * 100).round(0)
			end
		end

		return {counted: counted, total: total, percent: percent}

	end

	def bookings_metrics_by_status_and_time(from, to, option, location_ids, status_name)

		current_date = from
		status = Status.find_by_name(status_name)
		bookings_array = Hash.new

		time_diff = ((to.to_datetime - from.to_datetime).days/1.weeks)

		while current_date < to
			if time_diff >= 1
				current_date_limit = current_date + 1.weeks
				if current_date_limit > to
					current_date_limit = to
				end
			else
				current_date_limit = current_date + 1.days
			end
			if option.to_i == 0
				bookings = Booking.where(created_at: current_date.beginning_of_day..current_date_limit.beginning_of_day, location_id: location_ids).where('is_session = false or (is_session = true and is_session_booked = true)')
				status_bookings = bookings.where(status_id: status.id)
				if bookings.count == 0
					bookings_array[current_date.strftime("%d/%m/%Y")] = 0
				else
					bookings_array[current_date.strftime("%d/%m/%Y")] = ((status_bookings.count.to_f / bookings.count.to_f) * 100).round(0)
				end
			else
				bookings = Booking.where(start: current_date.beginning_of_day..current_date_limit.beginning_of_day, location_id: location_ids).where('is_session = false or (is_session = true and is_session_booked = true)')
				status_bookings = bookings.where(status_id: status.id)
				if bookings.count == 0
					bookings_array[current_date.strftime("%d/%m/%Y")] = 0
				else
					bookings_array[current_date.strftime("%d/%m/%Y")] = ((status_bookings.count.to_f / bookings.count.to_f) * 100).round(0)
				end
			end
			if time_diff >= 1
				current_date = current_date + 1.weeks
			else
				current_date = current_date + 1.days
			end
		end

		count_hash = [{
			name: "%",
			data: bookings_array
		}]

		return bookings_array

	end

	def bookings_metrics_by_status_and_services(from, to, option, location_ids, status_name, services_ids)
		status = Status.find_by_name(status_name)
		count_hash = Hash.new
		bookings_array = []

		Service.find(services_ids).each do |service|
			counted = 0
			total = 0
			percent = 0

			if option.to_i == 0
				bookings = Booking.where(created_at: from..to, location_id: location_ids, service_id: service.id).where('is_session = false or (is_session = true and is_session_booked = true)')
				status_bookings = bookings.where(status_id: status.id)
				if bookings.count > 0
					counted = status_bookings.count
					total = bookings.count
					percent = ((counted.to_f / total.to_f) * 100).round(0)
				end
			else
				bookings = Booking.where(start: from..to, location_id: location_ids, service_id: service.id).where('is_session = false or (is_session = true and is_session_booked = true)')
				status_bookings = bookings.where(status_id: status.id)
				if bookings.count > 0
					counted = status_bookings.count
					total = bookings.count
					percent = ((counted.to_f / total.to_f) * 100).round(0)
				end
			end
			if percent > 0
				count_hash[service.name] = percent
				bookings_array << {"name" => service.name, :data => {"Servicio" => percent}}
			end
		end

		puts count_hash.inspect

		return bookings_array

	end

end
