json.extract! @location, :id, :name, :address, :second_address, :phone, :longitude, :latitude, :company_id, :location_times, :latitude, :longitude
json.description @location.company.description
json.categorized_services @location.api_categorized_services
json.favorite @mobile_user.favorite_locations.include?(@location)
json.logo @location.company.logo && @location.company.logo.page && @location.company.logo.page.url ? request.protocol + request.host_with_port + @location.company.logo.page.url : ""
json.photo @location.image1 && @location.image1.mobile && @location.image1.mobile.url ? request.protocol + request.host_with_port + @location.image1.mobile.url : ""