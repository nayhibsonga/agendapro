json.array!(@results) do |result|
  json.id result[0].id
  json.location_id result[1].id
  json.company_name result[0].company.name
  json.service_name result[0].name
  json.normal_price result[0].price
  json.min_price result[0].price*(100-result[0].get_max_time_discount)/100
  json.promo_photo result[0].time_promo_photo ? result[0].time_promo_photo.url : ""
end