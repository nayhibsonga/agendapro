module ApplicationHelper

	def int_with_variation(int, past_int)
		if past_int > 0
			variation = ((int - past_int)/past_int.to_f).round(2)
			if variation > 0
				variation_class = 'positive-variation'
				icon = 'fa-arrow-up'
			elsif variation < 0
				variation_class = 'negative-variation'
				icon = 'fa-arrow-down'
			else
				variation_class = ''
				icon = 'fa-minus'
			end
			return (int.to_s+' (<span class="'+variation_class+'"><i class="fa '+icon+'"></i></span> '+(100*variation.abs).round(2).to_s+' %)').html_safe
		else
			return int.to_s
		end
	end

	def float_with_variation(float, past_float)
		if past_float > 0
			variation = ((float - past_float)/past_float).round(2)
			if variation > 0
				variation_class = 'positive-variation'
				icon = 'fa-arrow-up'
			elsif variation < 0
				variation_class = 'negative-variation'
				icon = 'fa-arrow-down'
			else
				variation_class = ''
				icon = 'fa-minus'
			end
			return (float.round(2).to_s+' (<span class="'+variation_class+'"><i class="fa '+icon+'"></i></span> '+(100*variation.abs).round(2).to_s+' %)').html_safe
		else
			return float.round(2).to_s
		end
	end

	def percentage_with_variation(float, past_float)
		if past_float > 0
			variation = ((float - past_float)/past_float).round(2)
			if variation > 0
				variation_class = 'positive-variation'
				icon = 'fa-arrow-up'
			elsif variation < 0
				variation_class = 'negative-variation'
				icon = 'fa-arrow-down'
			else
				variation_class = ''
				icon = 'fa-minus'
			end
			return ((100*float).round(2).to_s+' % (<span class="'+variation_class+'"><i class="fa '+icon+'"></i></span> '+(100*variation.abs).round(2).to_s+' %)').html_safe
		else
			return (100*float).round(2).to_s+' %'
		end
	end

	# Reporting
	# Count
	def booking_count(time_range_id, offset, company_id)
		if time_range_id == 0
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).count
		elsif time_range_id == 1
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).count
		elsif time_range_id == 2
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).count
		elsif time_range_id == 3
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).count
		else
			return 0
		end			
	end

	def service_booking_count(time_range_id, offset, service_id)
		if service_id == 0
			service = Service.where(active: true)
			company_id = service.first.company_id
		else
			service = Service.find(service_id)
			company_id = service.company_id
		end
		if time_range_id == 0
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: service, start: (1+offset).weeks.ago..offset.weeks.ago).count
		elsif time_range_id == 1
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: service, start: (1+offset).months.ago..offset.months.ago).count
		elsif time_range_id == 2
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: service, start: 2.months.ago..Time.now).count
		elsif time_range_id == 3
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: service, start: 2.months.ago..2.months.from_now).count
		else
			return 0
		end			
	end

	def provider_service_booking_count(time_range_id, offset, service_id, provider_id)
		if service_id == 0
			service = Service.where(active: true)
			company_id = service.first.company_id
		else
			service = Service.find(service_id)
			company_id = service.company_id
		end
		if provider_id == 0
			provider_id = ServiceProvider.where(company_id: company_id, active: true)
		end
		if time_range_id == 0
			return Booking.where(service_provider_id: provider_id, location_id: Location.where(company_id: company_id, active: true), service_id: service, start: (1+offset).weeks.ago..offset.weeks.ago).count
		elsif time_range_id == 1
			return Booking.where(service_provider_id: provider_id, location_id: Location.where(company_id: company_id, active: true), service_id: service, start: (1+offset).months.ago..offset.months.ago).count
		elsif time_range_id == 2
			return Booking.where(service_provider_id: provider_id, location_id: Location.where(company_id: company_id, active: true), service_id: service, start: 2.months.ago..Time.now).count
		elsif time_range_id == 3
			return Booking.where(service_provider_id: provider_id, location_id: Location.where(company_id: company_id, active: true), service_id: service, start: 2.months.ago..2.months.from_now).count
		else
			return 0
		end			
	end

	def location_service_booking_count(time_range_id, offset, service_id, location_id)
		if service_id == 0
			service = Service.where(active: true)
			company_id = service.first.company_id
		else
			service = Service.find(service_id)
			company_id = service.company_id
		end
		if location_id == 0
			location_id = Location.where(company_id: company_id, active: true)
		end
		if time_range_id == 0
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location_id, service_id: service, start: (1+offset).weeks.ago..offset.weeks.ago).count
		elsif time_range_id == 1
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location_id, service_id: service, start: (1+offset).months.ago..offset.months.ago).count
		elsif time_range_id == 2
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location_id, service_id: service, start: 2.months.ago..Time.now).count
		elsif time_range_id == 3
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location_id, service_id: service, start: 2.months.ago..2.months.from_now).count
		else
			return 0
		end			
	end

	def location_booking_count(time_range_id, offset, location_id)
		if location_id == 0
			location = Location.where(active: true)
			company_id = location.first.company_id
		else
			location = Location.find(location_id)
			company_id = location.company_id
		end
		if time_range_id == 0
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).count
		elsif time_range_id == 1
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).count
		elsif time_range_id == 2
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).count
		elsif time_range_id == 3
			return Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).count
		else
			return 0
		end			
	end

	def provider_booking_count(time_range_id, offset, provider_id)
		if provider_id == 0
			provider = ServiceProvider.where(active: true)
			company_id = provider.first.company_id
		else
			provider = ServiceProvider.find(provider_id)
			company_id = provider.company_id
		end
		if time_range_id == 0
			return Booking.where(service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).count
		elsif time_range_id == 1
			return Booking.where(service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).count
		elsif time_range_id == 2
			return Booking.where(service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).count
		elsif time_range_id == 3
			return Booking.where(service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).count
		else
			return 0
		end			
	end

	def status_booking_count(time_range_id, offset, status_id, company_id)
		if status_id == 0
			status_id = Status.all
		end
		if time_range_id == 0
			return Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).count
		elsif time_range_id == 1
			return Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).count
		elsif time_range_id == 2
			return Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).count
		elsif time_range_id == 3
			return Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).count
		else
			return 0
		end			
	end

	# Occupation
	def booking_occupation(time_range_id, offset, company_id)
		occupation_sum = 0.0
		Location.where(company_id: company_id, active:true).each do |location|
			occupation_sum += location_booking_occupation(time_range_id, offset, location.id)
		end
		return occupation_sum/Location.where(company_id: company_id, active:true).count
	end

	def location_booking_occupation(time_range_id, offset, location_id)
		occupation_sum = 0.0
		Location.find(location_id).service_providers.where(active:true).each do |service_provider|
			occupation_sum += provider_booking_occupation(time_range_id, offset, service_provider.id)
		end
		return occupation_sum/Location.find(location_id).service_providers.count
	end

	def provider_booking_occupation(time_range_id, offset, provider_id)
		available_time = 0.0
		used_time = 0.0
		ServiceProvider.find(provider_id).provider_times.each do |provider_time|
			available_time += provider_time.close - provider_time.open
		end
		if time_range_id == 0
			Booking.where(service_provider_id: provider_id, start: (1+offset).weeks.ago..offset.weeks.ago).each do |booking|
				used_time += booking.end - booking.start
			end
		elsif time_range_id == 1
			Booking.where(service_provider_id: provider_id, start: (1+offset).months.ago..offset.months.ago).each do |booking|
				used_time += (booking.end - booking.start)/(Time.now.days_in_month/7)
			end
		elsif time_range_id == 2
			eq_weeks = (((Time.now - 4.hours) - 2.months.ago)/7.days).to_f
			Booking.where(service_provider_id: provider_id, start: 2.months.ago..Time.now).each do |booking|
				used_time += (booking.end - booking.start)/eq_weeks
			end
		elsif time_range_id == 3
			eq_weeks = ((2.months.from_now - 2.months.ago)/7.days).to_f
			Booking.where(service_provider_id: provider_id, start: 2.months.ago..2.months.from_now).each do |booking|
				used_time += (booking.end - booking.start)/eq_weeks
			end
		else
			used_time = 0.0
		end
		return used_time/available_time			
	end

	def status_booking_ranking3(time_range_id, offset, status_id, company_id)
		if status_id == 0
			status_id = Status.all
		end
		if time_range_id == 0
			ranking = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 1
			ranking = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 2
			ranking = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 3
			ranking = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).group(:service_id).limit(3).order('count_all desc').count
		else
			return 0
		end
		top3_count = 0
		ranking.each do |rank|
			top3_count += rank[1]
		end
		total = status_booking_count(time_range_id, offset, status_id, company_id)
		top3 = Hash[ ranking.first(3).map{ |c| [Service.find(c[0]).name,c[1]] } ]
		return top3.merge({ "Otros" => (total - top3_count) })
	end

	def provider_booking_ranking3(time_range_id, offset, provider_id)
		if provider_id == 0
			provider = ServiceProvider.where(active: true)
			company_id = provider.first.company_id
		else
			provider = ServiceProvider.find(provider_id)
			company_id = provider.company_id
		end
		if time_range_id == 0
			ranking = Booking.where(service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 1
			ranking = Booking.where(service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 2
			ranking = Booking.where(service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 3
			ranking = Booking.where(service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).group(:service_id).limit(3).order('count_all desc').count
		else
			return 0
		end
		top3_count = 0
		ranking.each do |rank|
			top3_count += rank[1]
		end
		total = provider_booking_count(time_range_id, offset, provider_id)
		top3 = Hash[ ranking.first(3).map{ |c| [Service.find(c[0]).name,c[1]] } ]
		return top3.merge({ "Otros" => (total - top3_count) })
	end

	def location_booking_ranking3(time_range_id, offset, location_id)
		if location_id == 0
			location = Location.where(active: true)
			company_id = location.first.company_id
		else
			location = Location.find(location_id)
			company_id = location.company_id
		end
		if time_range_id == 0
			ranking = Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 1
			ranking = Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 2
			ranking = Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).group(:service_id).limit(3).order('count_all desc').count
		elsif time_range_id == 3
			ranking = Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).group(:service_id).limit(3).order('count_all desc').count
		else
			return 0
		end
		top3_count = 0
		ranking.each do |rank|
			top3_count += rank[1]
		end
		total = location_booking_count(time_range_id, offset, location_id)
		top3 = Hash[ ranking.first(3).map{ |c| [Service.find(c[0]).name,c[1]] } ]
		return top3.merge({ "Otros" => (total - top3_count) })
	end

	def status_booking_by_day(time_range_id, offset, status_id, company_id)
		if status_id == 0
			status_id = Status.all
		end
		if time_range_id == 0
			by_day = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).group_by_day_of_week(:start, week_start: 1).count
		elsif time_range_id == 1
			by_day = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).group_by_day_of_week(:start, week_start: 1).count
		elsif time_range_id == 2
			by_day = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).group_by_day_of_week(:start, week_start: 1).count
		elsif time_range_id == 3
			by_day = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).group_by_day_of_week(:start, week_start: 1).count
		else
			return 0
		end

		return Hash[ by_day.map{ |c| [I18n.t(:"date.day_names")[c[0]],c[1]] } ]
	end

	def status_booking_by_hour(time_range_id, offset, status_id, company_id)
		if status_id == 0
			status_id = Status.all
		end
		by_hour = []
		(0..6).each do |i|
			day_name = I18n.t(:"date.day_names")[i]
			if time_range_id == 0
				booking_count = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			elsif time_range_id == 1
				booking_count = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			elsif time_range_id == 2
				booking_count = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			elsif time_range_id == 3
				booking_count = Booking.where(status_id: status_id, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			else
				return 0
			end
		end

		return by_hour
	end

	def location_booking_by_hour(time_range_id, offset, location_id)
		if location_id == 0
			location = Location.where(active: true)
			company_id = location.first.company_id
		else
			location = Location.find(location_id)
			company_id = location.company_id
		end
		by_hour = []
		(0..6).each do |i|
			day_name = I18n.t(:"date.day_names")[i]
			if time_range_id == 0
				booking_count = Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: (1+offset).weeks.ago..offset.weeks.ago).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			elsif time_range_id == 1
				booking_count = Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: (1+offset).months.ago..offset.months.ago).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			elsif time_range_id == 2
				booking_count = Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..Time.now).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			elsif time_range_id == 3
				booking_count = Booking.where(service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: 2.months.ago..2.months.from_now).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			else
				return 0
			end
		end

		return by_hour
	end
end