#!/usr/bin/env ruby

#Set Args before running the script
# Args:
# 0 => bookings_amount
# 1 => company_id
# 2 => location_id
# 3 => start_hour (don't worry about 1 digit hours, script does it. For example, if you want to start at 09:00, just write 9 in hour)
# 4 => end_hour (same as above)
# 5 => month (from 1 to 12)
# 6 => status [0|1|2|3|4|5|6](0 to use random)
# 7 => web_origin [0|false|true](0 to use random)
# 8 => payed [0|false|true](0 to use random)

#Example execution:
# ARGV = [300, 89, 167, 9, 18, 10, 3, true, false]
# load '/path_to/random_booking_generator.rb'
#

bookings_amount = ARGV[0].to_i
company_id = ARGV[1].to_i
location_id = ARGV[2].to_i
start_hour = ARGV[3].to_i
end_hour = ARGV[4].to_i
month = ARGV[5]
status = ARGV[6]
web_origin = ARGV[7]
payed = ARGV[8]

#Generals
statuses = [1, 2, 3, 4, 5, 6]
booleans = [false, true]
rdn_status = false
rdn_origin = false
rdn_pay = false
if status == 0 || status == '0'
		rdn_status = true
end
if web_origin == 0 || web_origin == '0'
	rdn_origin = true
end
if payed == 0 || payed == '0'
	rdn_pay = true
end

bookings_amount.times do
	if rdn_status
		status = statuses.sample
	end
	if rdn_origin
		web_origin = booleans.sample
	end
	if rdn_pay
		payed = booleans.sample
	end

	random_day = rand(1..29)
	random_day_str = random_day.to_s
	if random_day < 10
		random_day_str = "0" + random_day_str
	end

	random_hour = rand(start_hour..end_hour)
	random_hour_str = random_hour.to_s
	if random_hour < 10
		random_hour_str = "0" + random_hour_str
	end
	random_hour_end = random_hour + 1
	random_hour_end_str = random_hour_end.to_s
	if random_hour_end < 10
		random_hour_end_str = "0" + random_hour_end_str
	end

	random_minute = rand(0..59)
	random_minute_str = random_minute.to_s
	if random_minute < 10
		random_minute_str = "0" + random_minute_str
	end

	random_client = Client.where(company_id: company_id).pluck(:id).sample

	random_provider = ServiceProvider.where(location_id: location_id).pluck(:id).sample

	random_service = Service.where(id: ServiceStaff.where(service_provider_id: random_provider).pluck(:service_id)).pluck(:id).sample

	random_price = Service.where(id: ServiceStaff.where(service_provider_id: random_provider).pluck(:service_id)).pluck(:price).sample

	b = Booking.new(
		start: '2016-' + month.to_s + '-' + random_day_str + 'T' + random_hour_str + ':' + random_minute_str + ':00Z',
		:end => '2016-' + month.to_s + '-' + random_day_str + 'T' + random_hour_end_str + ':' + random_minute_str + ':00Z',
		client_id: random_client,
		service_id: random_service,
		service_provider_id: random_provider,
		location_id: location_id,
		status_id: status,
		send_mail: false,
		web_origin: web_origin,
    payed: payed,
    price: random_price
	)

	if b.save then puts "OK" else puts b.errors.full_messages.inspect end

end
