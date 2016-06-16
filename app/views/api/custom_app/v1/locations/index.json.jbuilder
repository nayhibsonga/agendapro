json.company_id @api_company.id
json.company_name @api_company.name
json.locations do
  json.array!(@locations) do |location|
    location_address = LocationAddress.new location.address
    json.extract! location, :id, :name, :second_address, :phone, :longitude, :latitude, :company_id, :location_times, :latitude, :longitude, :email
    json.address "#{location_address.route} #{location_address.street_number}"
    json.district "#{location_address.district}"
    json.city "#{location_address.city}"
    json.region "#{location_address.region}"
    json.country "#{location_address.country}"
    json.description location.company.description
    json.url location_url(location, format: :json)
    json.categorized_services location.api_categorized_services
    json.logo location.company.logo && location.company.logo.page && location.company.logo.page.url ? request.protocol + request.host_with_port + location.company.logo.page.url : ""
    json.photo location.image1 && location.image1.mobile && location.image1.mobile.url ? request.protocol + request.host_with_port + location.image1.mobile.url : ""
  end
end
json.promotions do
  json.array!(@results) do |result|
    json.id result[0].id
    json.location_id result[1].id
    json.company_name result[0].company.name
    json.service_name result[0].name
    json.promo_description result[0].promo_description.html_safe
    json.normal_price number_to_currency(result[0].price, currency: '$ ', separator: '.', delimeter: ',', precision: 0)
    json.min_price number_to_currency(result[0].price*(100-result[0].get_max_time_discount)/100, currency: '$ ', separator: '.', delimeter: ',', precision: 0)
    json.max_discount '-' + result[0].get_max_time_discount.to_s + '%'
    json.promo_photo result[0].time_promo_photo ? request.protocol + request.host_with_port + result[0].time_promo_photo.url : ""
    json.url request.protocol + request.host_with_port + '/show_time_promo?id=' + result[0].id.to_s + '&location_id=' + result[1].id.to_s
  end
end
json.feeds do
  json.array!(@app_feeds) do |app_feed|
    json.id app_feed.id
    json.title app_feed.title
    json.subtitle app_feed.subtitle
    json.body app_feed.body
    json.external_url app_feed.external_url
    json.promo_photo app_feed.image ? request.protocol + request.host_with_port + app_feed.image.url : ""
  end
end
