json.array!(@locations) do |location|
  location_address = LocationAddress.new location.address
  json.extract! location, :id, :second_address, :phone, :latitude, :longitude, :email, :company_id
  json.name location.company.name
  json.address "#{location_address.route} #{location_address.street_number}"
  json.district "#{location_address.district}"
  json.city "#{location_address.city}"
  json.region "#{location_address.region}"
  json.country "#{location_address.country}"
  json.url location_url(location, format: :json)
  json.favorite @mobile_user.favorite_locations.include?(@location)
  json.logo location.company.logo && location.company.logo.url ? request.protocol + request.host_with_port + location.company.logo.url : ""
end
