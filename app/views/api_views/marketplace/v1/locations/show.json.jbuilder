json.extract! @location, :id, :name, :address, :second_address, :phone, :longitude, :latitude, :company_id, :latitude, :longitude
json.district @location.district.name
json.city @location.district.city.name
json.region @location.district.city.region.name
json.country @location.district.city.region.country.name
json.description @location.company.description
json.location_times @location.location_times do |location_time|
	json.open location_time.open.strftime('%H:%M')
	json.close location_time.close.strftime('%H:%M')
	json.short_day @short_days[location_time.day_id - 1]
	json.long_day @long_days[location_time.day_id - 1]
end
json.categorized_services @location.api_categorized_services
json.favorite @api_user.favorite_locations.include?(@location)
json.logo @location.company.logo && @location.company.logo.page && @location.company.logo.page.url ? request.protocol + request.host_with_port + @location.company.logo.page.url : ""
json.photo @location.image1 && @location.image1.mobile && @location.image1.mobile.url ? request.protocol + request.host_with_port + @location.image1.mobile.url : ""
json.show_comments false