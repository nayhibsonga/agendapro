json.extract! @location, :id, :name, :address, :second_address, :phone, :longitude, :latitude, :company_id, :location_times
json.description @location.company.description
json.categorized_services @location.categorized_services