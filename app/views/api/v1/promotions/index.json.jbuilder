json.array!(@results) do |result|
  json.id result[0].id
  json.location_id result[1].id
  json.company_name result[0].company.name
  json.service_name result[0].name
  json.normal_price number_to_currency(result[0].price, currency: '$ ', separator: ',', delimeter: '.', precision: 0)
  json.min_price number_to_currency(result[0].price*(100-result[0].get_max_time_discount)/100, currency: '$ ', separator: ',', delimeter: '.', precision: 0)
  json.max_discount '-%' + result[0].get_max_time_discount.to_s
  json.promo_photo result[0].time_promo_photo ? request.protocol + request.host_with_port + result[0].time_promo_photo.url : ""
end