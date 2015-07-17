json.array!(@locations) do |location|
  json.extract! location, :id, :name, :address, :second_address, :phone, :latitude, :longitude, :email, :company_id
  json.district location.district.name
  json.city location.district.city.name
  json.region location.district.city.region.name
  json.country location.district.city.region.country.name
  json.url location_url(location, format: :json)
end