module ApplicationHelper

	def split_name(full_name)

		returnHash = Hash.new
		nameArray = []
        nameArray = full_name.to_s.gsub(/\s+/, ' ').split(' ')
        if nameArray.length == 0

        elsif nameArray.length == 1
          returnHash[:first_name] = nameArray[0] unless nameArray[0].blank?
          returnHash[:last_name] = ""
        elsif nameArray.length == 2
          returnHash[:first_name] = nameArray[0] unless nameArray[0].blank?
          returnHash[:last_name] = nameArray[1] unless nameArray[1].blank?
        elsif nameArray.length == 3
          returnHash[:first_name] = nameArray[0] unless nameArray[0].blank?
          returnHash[:last_name] = nameArray[1] + ' ' + nameArray[2]
        else 
          returnHash[:first_name] = nameArray[0] + ' ' + nameArray[1]
          last_name = ''
          (2..nameArray.length - 1).each do |i|
            last_name += nameArray[i]+' '
          end
          strLen = last_name.length
          last_name = last_name[0..strLen-1]
          returnHash[:last_name] = last_name unless last_name.blank?
        end

        return returnHash

	end

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
			return (int.round(0).to_s+' (<span class="'+variation_class+'"><i class="fa '+icon+'"></i></span> '+(100*variation.abs).round(2).to_s+' %)').html_safe
		else
			return int.round(0).to_s
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

	def price_int_with_variation(int, past_int)
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
			return (int.round(0).to_s+' (<span class="'+variation_class+'"><i class="fa '+icon+'"></i></span> '+(100*variation.abs).round(2).to_s+' %)').html_safe
		else
			return int.round(0).to_s
		end
	end

	def price_float_with_variation(float, past_float)
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

	# Reporting
	# Count
	def booking_count(from, to, status, option, company_id)
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).count
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).count
		end
	end

	def service_booking_count(from, to, status, option, service_id)
		if service_id == 0
			service = Service.where(active: true)
			company_id = service.first.company_id
		else
			service = Service.find(service_id)
			company_id = service.company_id
		end
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: service, start: from.beginning_of_day..to.end_of_day).count
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: service, created_at: from.beginning_of_day..to.end_of_day).count
		end
	end

	def provider_service_booking_count(from, to, status, option, service_id, provider_id)
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
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider_id, location_id: Location.where(company_id: company_id, active: true), service_id: service, start: from.beginning_of_day..to.end_of_day).count
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider_id, location_id: Location.where(company_id: company_id, active: true), service_id: service, created_at: from.beginning_of_day..to.end_of_day).count
		end
	end

	def location_service_booking_count(from, to, status, option, service_id, location_id)
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
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location_id, service_id: service, start: from.beginning_of_day..to.end_of_day).count
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location_id, service_id: service, created_at: from.beginning_of_day..to.end_of_day).count
		end
	end

	def location_booking_count(from, to, status, option, location_id)
		if location_id == 0
			location = Location.where(active: true)
			company_id = location.first.company_id
		else
			location = Location.find(location_id)
			company_id = location.company_id
		end
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).count
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).count
		end
	end

	def provider_booking_count(from, to, status, option, provider_id)
		if provider_id == 0
			provider = ServiceProvider.where(active: true)
			company_id = provider.first.company_id
		else
			provider = ServiceProvider.find(provider_id)
			company_id = provider.company_id
		end
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).count
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).count
		end
	end

	def status_booking_count(from, to, status, option, company_id)
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).count
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).count
		end
	end

	# Occupation
	def booking_occupation(from, to, status, option, company_id)
		occupation_sum = 0.0
		locations = Location.where(company_id: company_id, active:true).count
		Location.where(company_id: company_id, active:true).each do |location|
			occupation_sum += location_booking_occupation(from, to, status, option, location.id)
		end
		if locations > 0
			return occupation_sum/locations
		else
			return 0
		end
	end

	def location_booking_occupation(from, to, status, option, location_id)
		occupation_sum = 0.0
		providers = Location.find(location_id).service_providers.where(active:true).count
		Location.find(location_id).service_providers.where(active:true).each do |service_provider|
			occupation_sum += provider_booking_occupation(from, to, status, option, service_provider.id)
		end
		if providers > 0
			return occupation_sum/providers
		else
			return 0
		end
	end

	def provider_booking_occupation(from, to, status, option, provider_id)
		available_time = 0.0
		used_time = 0.0
		ServiceProvider.find(provider_id).provider_times.each do |provider_time|
			available_time += provider_time.close - provider_time.open
		end
		if option == 1
			Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider_id, start: from.beginning_of_day..to.end_of_day).each do |booking|
				used_time += booking.end - booking.start
			end
		else
			Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider_id, created_at: from.beginning_of_day..to.end_of_day).each do |booking|
				used_time += booking.end - booking.start
			end
		end
		if available_time > 0
			return used_time/available_time
		else
			return 0
		end
	end

	def status_booking_ranking3(from, to, status, option, company_id)
		if option == 1
			ranking = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).group(:service_id).limit(10).order('count_all desc').count
		else
			ranking = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).group(:service_id).limit(10).order('count_all desc').count
		end
		top3_count = 0
		ranking.each do |rank|
			top3_count += rank[1]
		end
		total = status_booking_count(from, to, status, option, company_id)
		top3 = Hash[ ranking.first(10).map{ |c| [Service.find(c[0]).name,c[1]] } ]
		return top3.merge({ "Otros" => (total - top3_count) })
	end

	def provider_booking_ranking3(from, to, status, option, provider_id)
		if provider_id == 0
			provider = ServiceProvider.where(active: true)
			company_id = provider.first.company_id
		else
			provider = ServiceProvider.find(provider_id)
			company_id = provider.company_id
		end
		if option == 1
			ranking = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).group(:service_id).limit(10).order('count_all desc').count
		else
			ranking = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).group(:service_id).limit(10).order('count_all desc').count
		end
		top3_count = 0
		ranking.each do |rank|
			top3_count += rank[1]
		end
		total = provider_booking_count(from, to, status, option, provider_id)
		top3 = Hash[ ranking.first(10).map{ |c| [Service.find(c[0]).name,c[1]] } ]
		return top3.merge({ "Otros" => (total - top3_count) })
	end

	def location_booking_ranking3(from, to, status, option, location_id)
		if location_id == 0
			location = Location.where(active: true)
			company_id = location.first.company_id
		else
			location = Location.find(location_id)
			company_id = location.company_id
		end
		if option == 1
			ranking = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).group(:service_id).limit(10).order('count_all desc').count
		else
			ranking = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).group(:service_id).limit(10).order('count_all desc').count
		end
		top3_count = 0
		ranking.each do |rank|
			top3_count += rank[1]
		end
		total = location_booking_count(from, to, status, option, location_id)
		top3 = Hash[ ranking.first(10).map{ |c| [Service.find(c[0]).name,c[1]] } ]
		return top3.merge({ "Otros" => (total - top3_count) })
	end

	def status_booking_by_day(from, to, status, option, company_id)
		if option == 1
			by_day = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).group_by_day_of_week(:start, week_start: 1).count
		else
			by_day = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).group_by_day_of_week(:start, week_start: 1).count
		end

		return Hash[ by_day.map{ |c| [I18n.t(:"date.day_names")[c[0]],c[1]] } ]
	end

	def status_booking_by_hour(from, to, status, option, company_id)
		by_hour = []
		(0..6).each do |i|
			day_name = I18n.t(:"date.day_names")[i]
			if option == 1
				booking_count = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			else
				booking_count = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			end
		end

		return by_hour
	end

	def location_booking_by_hour(from, to, status, option, location_id)
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
			if option == 1
				booking_count = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			else
				booking_count = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).where('EXTRACT(DOW from ("start"::timestamptz)) = ?', i).group_by_hour_of_day(:start, format: "%l %P").count
				by_hour.push( { :name => day_name, :data => booking_count } )
			end
		end

		return by_hour
	end

	#Revenue
	def booking_revenue(from, to, status, option, company_id)
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).sum(:price)
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).sum(:price)
		end
	end

	def service_booking_revenue(from, to, status, option, service_id)
		if service_id == 0
			service = Service.where(active: true)
			company_id = service.first.company_id
		else
			service = Service.find(service_id)
			company_id = service.company_id
		end
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: service, start: from.beginning_of_day..to.end_of_day).sum(:price)
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: service, created_at: from.beginning_of_day..to.end_of_day).sum(:price)
		end
	end

	def provider_service_booking_revenue(from, to, status, option, service_id, provider_id)
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
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider_id, location_id: Location.where(company_id: company_id, active: true), service_id: service, start: from.beginning_of_day..to.end_of_day).sum(:price)
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider_id, location_id: Location.where(company_id: company_id, active: true), service_id: service, created_at: from.beginning_of_day..to.end_of_day).sum(:price)
		end
	end

	def location_service_booking_revenue(from, to, status, option, service_id, location_id)
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
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location_id, service_id: service, start: from.beginning_of_day..to.end_of_day).sum(:price)
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location_id, service_id: service, created_at: from.beginning_of_day..to.end_of_day).sum(:price)
		end
	end

	def location_booking_revenue(from, to, status, option, location_id)
		if location_id == 0
			location = Location.where(active: true)
			company_id = location.first.company_id
		else
			location = Location.find(location_id)
			company_id = location.company_id
		end
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).sum(:price)
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: location, service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).sum(:price)
		end
	end

	def provider_booking_revenue(from, to, status, option, provider_id)
		if provider_id == 0
			provider = ServiceProvider.where(active: true)
			company_id = provider.first.company_id
		else
			provider = ServiceProvider.find(provider_id)
			company_id = provider.company_id
		end
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).sum(:price)
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: provider, location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).sum(:price)
		end
	end

	def status_booking_revenue(from, to, status, option, company_id)
		if option == 1
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), start: from.beginning_of_day..to.end_of_day).sum(:price)
		else
			return Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(status_id: status, service_provider_id: ServiceProvider.where(company_id: company_id, active: true), location_id: Location.where(company_id: company_id, active: true), service_id: Service.where(company_id: company_id, active: true), created_at: from.beginning_of_day..to.end_of_day).sum(:price)
		end
	end

	def number_to_day(number)
		case number
		when 1
			return "Lunes"
		when 2
			return "Martes"
		when 3
			return "Miércoles"
		when 4
			return "Jueves"
		when 5
			return "Viernes"
		when 6
			return "Sábado"
		when 7
			return "Domingo"
		end
	end

	def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(('<i class="fa fa-trash-o"> ' + name + '</i>').html_safe, "remove_fields(this)", class: 'btn btn-red')
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

	def code_to_payment_method(code)

		return_str = "Sin información"

		if code == "03" || code == "3"
			return_str = "WebPay"
		elsif code == "04" || code == "4"
			return_str = "Banco de Chile"
		elsif code == "05" || code == "5"
			return_str = "Banco BCI"
		elsif code == "06" || code == "6"
			return_str = "Banco TBanc"
		elsif code == "07" || code == "7"
			return_str = "BancoEstado"
		elsif code == "16"
			return_str = "Banco BBVA"
		end

		return return_str
		
	end
end
