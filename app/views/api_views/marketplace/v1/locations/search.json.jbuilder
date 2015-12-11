json.array!(@results) do |location|
  json.extract! location, :id, :address, :second_address, :phone, :latitude, :longitude, :email, :company_id
  json.name location.company.name
  json.description location.company.description
  json.district location.district.name
  json.city location.district.city.name
  json.region location.district.city.region.name
  json.country location.district.city.region.country.name
  json.url location_url(location, format: :json)
  json.favorite @api_user.favorite_locations.include?(location)
  json.logo @location.company.logo && @location.company.logo.page && @location.company.logo.page.url && @location.company.logo.page.url != "/assets/logo_vacio.png" ? request.protocol + request.host_with_port + @location.company.logo.page.url : request.protocol + request.host_with_port + "/assets/default_marketplace.png"
  json.photo location.image1 && location.image1.mobile && location.image1.mobile.url ? request.protocol + request.host_with_port + location.image1.mobile.url : ""
  json.featured_services location.services_top4
end