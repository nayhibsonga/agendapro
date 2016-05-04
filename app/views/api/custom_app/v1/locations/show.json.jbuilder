location_address = LocationAddress.new @location.address
json.extract! @location, :id, :name, :second_address, :phone, :longitude, :latitude, :company_id, :location_times, :latitude, :longitude
json.address "#{location_address.route} #{location_address.street_number}"
json.district "#{location_address.district}"
json.city "#{location_address.city}"
json.region "#{location_address.region}"
json.country "#{location_address.country}"
json.description @location.company.description
json.categorized_services @location.api_categorized_services
json.logo @location.company.logo && @location.company.logo.page && @location.company.logo.page.url ? request.protocol + request.host_with_port + @location.company.logo.page.url : ""
json.photo @location.image1 && @location.image1.mobile && @location.image1.mobile.url ? request.protocol + request.host_with_port + @location.image1.mobile.url : ""
