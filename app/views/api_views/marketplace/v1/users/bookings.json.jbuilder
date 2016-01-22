json.active_bookings @activeBookings.each do |booking|
	json.extract! booking, :id, :start, :end, :service_provider_id, :service_id, :location_id, :price
	json.service booking.service.name
	json.service_provider booking.service_provider.public_name
	json.location booking.location.name
	json.company booking.location.company.name
	json.access_token booking.access_token
end

json.past_bookings @lastBookings.each do |booking|
	json.extract! booking, :id, :start, :end, :service_provider_id, :service_id, :location_id, :price
	json.service booking.service.name
	json.service_provider booking.service_provider.public_name
	json.location booking.location.name
	json.company booking.location.company.name
	json.access_token booking.access_token
end

json.session_bookings do
	json.array!(@sessionBookings) do |session_booking|
		json.extract! session_booking, :id, :sessions_taken, :sessions_amount, :service_id
		json.service session_booking.service.name
		json.booked_sessions do
			json.array!(session_booking.bookings.where(:is_session_booked => true).order('start asc')) do |booking|
				json.extract! booking, :id, :start, :end, :service_provider_id, :service_id, :location_id
				json.service booking.service.name
				json.service_provider booking.service_provider.public_name
				json.editable (DateTime.now < (booking.start.to_datetime - booking.service.company.company_setting.before_edit_booking.hours) && booking.max_changes > 0)
			end
		end
		json.unbooked_sessions do
			json.array!(session_booking.bookings.where(:is_session_booked => false).order('created_at asc')) do |booking|
				json.extract! booking, :id
			end
		end
	end
end