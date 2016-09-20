json.array!(@locations) do |location|
  location_address = LocationAddress.new location.address
  json.extract! location, :id, :name, :second_address, :phone, :latitude, :longitude, :email, :company_id
  json.address "#{location_address.route} #{location_address.street_number}"
  json.district "#{location_address.district}"
  json.city "#{location_address.city}"
  json.region "#{location_address.region}"
  json.country "#{location_address.country}"
  json.url location_url(location, format: :json)
  json.logo location.company.logo && location.company.logo.url ? request.protocol + request.host_with_port + location.company.logo.url : ""
  json.photo location.image1 && location.image1.mobile && location.image1.mobile.url ? request.protocol + request.host_with_port + location.image1.mobile.url : ""
end
