json.array!(@available_time) do |available_hour|
  json.extract! available_hour, :date, :hour, :service_provider_id
  json.lock @lock
  json.service_id @service.id
  json.location_id @location.id
end