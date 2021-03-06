json.array!(@bookings) do |booking|
	json.extract! booking, :id, :start, :end, :status_id, :service_id, :service_provider_id, :user_id, :web_origin, :location_id, :provider_lock, :is_session, :is_session_booked, :user_session_confirmed, :notes, :price
	json.service booking.service.name
	json.provider booking.service_provider.public_name
	json.location booking.location.name
	json.location_address booking.location.long_address_with_second_address
	json.client_full_name booking.client.full_name
	json.client_email booking.client.email
	json.client_phone booking.client.phone
  json.company_name booking.location.company.name
end
