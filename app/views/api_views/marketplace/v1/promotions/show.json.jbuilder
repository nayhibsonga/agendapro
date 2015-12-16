json.id @service.id
json.location_id @location.id
json.latitude @location.latitude
json.longitude @location.longitude
json.address @location.get_full_address
json.phone @location.phone
json.logo @location.company.logo && @location.company.logo.page && @location.company.logo.page.url ? request.protocol + request.host_with_port + @location.company.logo.page.url : ""
json.booking_conditions @booking_conditions
json.booking_dates @booking_dates
json.discounts @discounts
json.company_name @service.company.name
json.service_name @service.name
json.promo_description @service.promo_description.html_safe
json.normal_price number_to_currency(@service.price, currency: '$ ', separator: '.', delimeter: ',', precision: 0)
json.min_price number_to_currency(@service.price*(100-@service.get_max_discount)/100, currency: '$ ', separator: '.', delimeter: ',', precision: 0)
json.max_discount '-' + @service.get_max_discount.to_s + '%'
json.promo_photo @service.time_promo_photo ? request.protocol + request.host_with_port + @service.time_promo_photo.url : ""
json.url request.protocol + request.host_with_port + '/show_time_promo?id=' + @service.id.to_s + '&location_id=' + @location.id.to_s
json.service_providers @service_providers_array