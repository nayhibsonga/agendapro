json.extract! @booking, :id, :start, :end, :price, :status_id, :service_id, :service_provider_id, :user_id, :web_origin, :location_id, :provider_lock, :is_session, :is_session_booked, :user_session_confirmed, :notes
json.service @booking.service.name
json.provider @booking.service_provider.public_name
json.location @booking.location.name