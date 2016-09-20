location_address = LocationAddress.new @location.address
json.extract! @location, :id, :name, :second_address, :phone, :longitude, :latitude, :company_id, :latitude, :longitude
json.address "#{location_address.route} #{location_address.street_number}"
json.district "#{location_address.district}"
json.city "#{location_address.city}"
json.region "#{location_address.region}"
json.country "#{location_address.country}"
json.description @location.company.description
json.location_times @location.location_times do |location_time|
	json.day_id location_time.day_id
	json.open location_time.open.strftime('%H:%M')
	json.close location_time.close.strftime('%H:%M')
	json.short_day @short_days[location_time.day_id - 1]
	json.long_day @long_days[location_time.day_id - 1]
end
json.categorized_services @location.api_categorized_services(true)
json.favorite @api_user.favorite_locations.include?(@location)
json.logo @location.company.logo && @location.company.logo.page && @location.company.logo.page.url && @location.company.logo.page.url.exclude?("/assets/logo_vacio") ? request.protocol + request.host_with_port + @location.company.logo.page.url : request.protocol + request.host_with_port + "/assets/default_marketplace.png"
json.photo @location.image2 && @location.image2.mobile && @location.image2.mobile.url ? request.protocol + request.host_with_port + @location.image2.mobile.url : ""
json.show_comments false
json.attributes @attributes.each do |attribute|
  json.id attribute.id
  json.name "#{attribute.name}"
  json.description "#{attribute.description}"
  json.datatype "#{attribute.datatype}"
  json.mandatory attribute.mandatory_on_workflow
  json.group_order attribute.attribute_group.order
  json.attribute_order attribute.order
  json.categories attribute.attribute_categories do |attribute_category|
    json.id attribute_category.id
    json.category attribute_category.category
  end
  json.slug "#{attribute.slug}"
end
