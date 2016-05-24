module ReportsHelper

	def bookings_count_by_status(from, to, option, location_ids, status_name)

		status = Status.find_by_name(status_name)
		counted = 0
		total = 0
		percent = 0

		if option.to_i == 0
			bookings = Booking.where(created_at: from..to, location_id: location_ids)
			status_bookings = bookings.where(status_id: status.id)
			if bookings.count > 0
				counted = status_bookings.count
				total = bookings.count
				percent = ((counted.to_f / total.to_f) * 100).round(0)
			end
		else
			bookings = Booking.where(start: from..to, location_id: location_ids)
			status_bookings = bookings.where(status_id: status.id)
			if bookings.count > 0
				counted = status_bookings.count
				total = bookings.count
				percent = ((counted.to_f / total.to_f) * 100).round(0)
			end
		end

		return {counted: counted, total: total, percent: percent}

	end

	def bookings_metrics_by_status(from, to, option, location_ids, status_name)

		current_date = from
		status = Status.find_by_name(status_name)
		bookings_array = Hash.new

		while current_date < to
			if option.to_i == 0
				bookings = Booking.where(created_at: current_date.beginning_of_day..current_date.end_of_day, location_id: location_ids)
				status_bookings = bookings.where(status_id: status.id)
				if bookings.count == 0
					bookings_array[current_date.beginning_of_day] = 0
				else
					bookings_array[current_date.beginning_of_day] = ((status_bookings.count.to_f / bookings.count.to_f) * 100).round(0)
				end
			else
				bookings = Booking.where(start: current_date.beginning_of_day..current_date.end_of_day, location_id: location_ids)
				status_bookings = bookings.where(status_id: status.id)
				if bookings.count == 0
					bookings_array[current_date.beginning_of_day] = 0
				else
					bookings_array[current_date.beginning_of_day] = ((status_bookings.count.to_f / bookings.count.to_f) * 100).round(0)
				end
			end
			current_date = current_date + 1.days
		end

		count_hash = [{
			name: "Porcentaje",
			data: bookings_array
		}]

		return count_hash

	end

	def bookings_metrics_by_status_and_services(from, to, option, location_ids, status_name, services_ids)
		status = Status.find_by_name(status_name)
		count_hash = Hash.new

		Service.find(services_ids).each do |service|
			counted = 0
			total = 0
			percent = 0

			if option.to_i == 0
				bookings = Booking.where(created_at: from..to, location_id: location_ids, service_id: service.id)
				status_bookings = bookings.where(status_id: status.id)
				if bookings.count > 0
					counted = status_bookings.count
					total = bookings.count
					percent = ((counted.to_f / total.to_f) * 100).round(0)
				end
			else
				bookings = Booking.where(start: from..to, location_id: location_ids, service_id: service.id)
				status_bookings = bookings.where(status_id: status.id)
				if bookings.count > 0
					counted = status_bookings.count
					total = bookings.count
					percent = ((counted.to_f / total.to_f) * 100).round(0)
				end
			end
			count_hash[service.name] = percent
		end

		puts count_hash.inspect

		return count_hash

	end

end
