json.array!(@results) do |location|
  location_address = LocationAddress.new location.address
  json.extract! location, :id, :second_address, :phone, :latitude, :longitude, :email, :company_id
  json.name location.company.name
  json.description location.company.description
  json.address "#{location_address.route} #{location_address.street_number}"
  json.district "#{location_address.district}"
  json.city "#{location_address.city}"
  json.region "#{location_address.region}"
  json.country "#{location_address.country}"
  json.url location_url(location, format: :json)
  json.favorite @api_user.favorite_locations.include?(location)
  json.logo location.company.logo && location.company.logo.page && location.company.logo.page.url && location.company.logo.page.url.exclude?("/assets/logo_vacio") ? request.protocol + request.host_with_port + location.company.logo.page.url : request.protocol + request.host_with_port + "/assets/default_marketplace.png"
  json.photo location.image1 && location.image1.mobile && location.image1.mobile.url ? request.protocol + request.host_with_port + location.image1.mobile.url : ""
  json.featured_services location.services_top4
end
