json.extract! @location, :id, :name, :address, :second_address, :phone, :longitude, :latitude, :company_id, :location_times
json.description @location.company.description
json.categorized_services @location.categorized_services
json.favorite @mobile_user.favorite_locations.include?(@location)
json.logo @location.company.logo ? request.protocol + request.host_with_port + @location.company.logo.url : nil