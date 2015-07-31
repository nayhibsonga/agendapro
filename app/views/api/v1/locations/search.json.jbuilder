json.array!(@results) do |location|
  json.extract! location, :id, :name, :address, :second_address, :phone, :latitude, :longitude, :email, :company_id
  json.district location.district.name
  json.city location.district.city.name
  json.region location.district.city.region.name
  json.country location.district.city.region.country.name
  json.url location_url(location, format: :json)
  json.favorite @mobile_user.favorite_locations.include?(@location)
  json.logo location.company.logo ? request.protocol + request.host_with_port + location.company.logo.url : nil
end