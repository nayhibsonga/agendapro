module Api
  module V2
  	class ServiceProvidersController < V2Controller
  	  before_action :check_available_hours_params, only: [:available_hours]

      def available_hours
		@service = Service.find(params[:service_id])
		service_duration = @service.duration
		@date = Date.parse(params[:date])
		@location = Location.find(params[:location_id])
		company_setting = CompanySetting.find(Company.find(@location.company_id).company_setting)
		cancelled_id = Status.find_by(name: 'Cancelado').id
		if params[:id] == "0"
			# Data
			provider_breaks = ProviderBreak.where(:service_provider_id => @location.service_providers.pluck(:id))
			location_times_first = @location.location_times.order(:open).first
			location_times_final = @location.location_times.order(close: :desc).first

			# Block Hour
			# {
			#   status: 'available/occupied/empty/past',
			#   hour: {
			#     start: '10:00',
			#     end: '10:30',
			#     provider: ''
			#   }
			# }

			@available_time = Array.new

			# Variable Data
			day = @date.cwday
			ordered_providers = ServiceProvider.where(id: @service.service_providers.pluck(:id), location_id: @location.id, active: true, online_booking: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(@date) }
			location_times = @location.location_times.where(day_id: day).order(:open)

			if location_times.length > 0

				location_times_first_open = location_times_first.open
				location_times_final_close = location_times_final.close

				location_times_first_open_start = location_times_first_open

				while (location_times_first_open_start <=> location_times_final_close) < 0 do

					location_times_first_open_end = location_times_first_open_start + service_duration.minutes

					status = 'empty'
					hour = {
					  :start => '',
					  :end => ''
					}

					open_hour = location_times_first_open_start.hour
					open_min = location_times_first_open_start.min
					start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

					next_open_hour = location_times_first_open_end.hour
					next_open_min = location_times_first_open_end.min
					end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


					start_time_block = DateTime.new(@date.year, @date.mon, @date.mday, open_hour, open_min)
					end_time_block = DateTime.new(@date.year, @date.mon, @date.mday, next_open_hour, next_open_min)
					now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
					before_now = start_time_block - company_setting.before_booking / 24.0
					after_now = now + company_setting.after_booking * 30

					available_provider = ''
					ordered_providers.each do |provider|
					  provider_time_valid = false
					  provider_free = true
					  provider.provider_times.where(day_id: day).each do |provider_time|
					    if (provider_time.open - location_times_first_open_end)*(location_times_first_open_start - provider_time.close) > 0
					    	if provider_time.open <= location_times_first_open_start && provider_time.close >= location_times_first_open_end
		        		provider_time_valid = true
				      	end
					    end
					    break if provider_time_valid
					  end
					  if provider_time_valid
					    if (before_now <=> now) < 1
					      status = 'past'
					    elsif (after_now <=> end_time_block) < 1
					      status = 'past'
					    else
					      status = 'occupied'
					      Booking.where(:service_provider_id => provider.id, :start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |provider_booking|
					        unless provider_booking.status_id == cancelled_id
					          if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
					            if !@service.group_service || @service.id != provider_booking.service_id
					              provider_free = false
					              break
					            elsif @service.group_service && @service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => @service.id, :start => start_time_block).count >= @service.capacity
					              provider_free = false
					              break
					            end
					          end
					        end
					      end
					      if @service.resources.count > 0
					        @service.resources.each do |resource|
					          if !@location.resource_locations.pluck(:resource_id).include?(resource.id)
					            provider_free = false
					            break
					          end
					          used_resource = 0
					          group_services = []
					          @location.bookings.where(:start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |location_booking|
					            if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
					              if location_booking.service.resources.include?(resource)
					                if !location_booking.service.group_service
					                  used_resource += 1
					                else
					                  if location_booking.service != @service || location_booking.service_provider != provider
					                    group_services.push(location_booking.service_provider.id)
					                  end
					                end
					              end
					            end
					          end
					          if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: @location.id).first.quantity
					            provider_free = false
					            break
					          end
					        end
					      end
					      ProviderBreak.where(:service_provider_id => provider.id).each do |provider_break|
					        if (provider_break.start.to_datetime - end_time_block)*(start_time_block - provider_break.end.to_datetime) > 0
					          provider_free = false
					        end
					        break if !provider_free
					      end
					      if provider_free
					        status = 'available'
					        available_provider = provider.id
					      end
					    end
					    break if ['past','available'].include? status
					  end
					end

					if ['past','available','occupied'].include? status
					  hour = {
					    :start => start_block,
					    :end => end_block,
					  }
					end

					block_hour = Hash.new

					block_hour[:date] = @date
					block_hour[:hour] = hour
					block_hour[:service_provider_id] = available_provider

					@available_time << block_hour if status == 'available'
					location_times_first_open_start = location_times_first_open_start + service_duration.minutes
				end
			end

		else

			# Data
			provider = ServiceProvider.find(params[:id])
			provider_breaks = provider.provider_breaks
			provider_times_first = provider.provider_times.order(:open).first
			provider_times_final = provider.provider_times.order(close: :desc).first

			# Block Hour
			# {
			#   status: 'available/occupied/empty/past',
			#   hour: {
			#     start: '10:00',
			#     end: '10:30',
			#     provider: ''
			#   }
			# }

			@available_time = Array.new

			# Variable Data
			day = @date.cwday
			provider_times = provider.provider_times.where(day_id: day).order(:open)

			if provider_times.length > 0

				provider_times_first_open = provider_times_first.open
				provider_times_final_close = provider_times_final.close

				provider_times_first_open_start = provider_times_first_open

				time_offset = 0

				while (provider_times_first_open_start <=> provider_times_final_close) < 0 do

					provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes

					status = 'empty'
					hour = {
					  :start => '',
					  :end => ''
					}

					available_provider = ''
					provider_time_valid = false
					provider_free = true
					provider_times.each do |provider_time|
		      if (provider_time.open - provider_times_first_open_end)*(provider_times_first_open_start - provider_time.close) > 0
		        if provider_time.open > provider_times_first_open_start
		          time_offset += (provider_time.open - provider_times_first_open_start)/1.minutes
		          if time_offset < service_duration
		            provider_times_first_open_start = provider_time.open
		            provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes
		          end
		        end
		        if provider_time.open <= provider_times_first_open_start && provider_time.close >= provider_times_first_open_end
		          provider_time_valid = true
		        elsif provider_time.open <= provider_times_first_open_start
		          time_offset = time_offset % service_duration
		          provider_times_first_open_start -= time_offset.minutes
		          provider_times_first_open_end -= time_offset.minutes
		          time_offset = 0
		        else
		          provider_times_first_open_start -= time_offset.minutes
		          provider_times_first_open_end -= time_offset.minutes
		          time_offset = 0
		        end
		      end
		      break if provider_time_valid
		    end

					open_hour = provider_times_first_open_start.hour
					open_min = provider_times_first_open_start.min
					start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

					next_open_hour = provider_times_first_open_end.hour
					next_open_min = provider_times_first_open_end.min
					end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


					start_time_block = DateTime.new(@date.year, @date.mon, @date.mday, open_hour, open_min)
					end_time_block = DateTime.new(@date.year, @date.mon, @date.mday, next_open_hour, next_open_min)
					now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
					before_now = start_time_block - company_setting.before_booking / 24.0
					after_now = now + company_setting.after_booking * 30

					if provider_time_valid
					  if (before_now <=> now) < 1
					    status = 'past'
					  elsif (after_now <=> end_time_block) < 1
					    status = 'past'
					  else
					    status = 'occupied'
					    Booking.where(:service_provider_id => provider.id, :start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |provider_booking|
					      unless provider_booking.status_id == cancelled_id
					        if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
					          if !@service.group_service || @service.id != provider_booking.service_id
					            provider_free = false
					            break
					          elsif @service.group_service && @service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => @service.id, :start => start_time_block).count >= @service.capacity
					            provider_free = false
					            break
					          end
					        end
					      end
					    end
					    if @service.resources.count > 0
					      @service.resources.each do |resource|
					        if !@location.resource_locations.pluck(:resource_id).include?(resource.id)
					          provider_free = false
					          break
					        end
					        used_resource = 0
					        group_services = []
					        @location.bookings.where(:start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |location_booking|
					          if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
					            if location_booking.service.resources.include?(resource)
					              if !location_booking.service.group_service
					                used_resource += 1
					              else
					                if location_booking.service != @service || location_booking.service_provider != provider
					                  group_services.push(location_booking.service_provider.id)
					                end
					              end
					            end
					          end
					        end
					        if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: @location.id).first.quantity
					          provider_free = false
					          break
					        end
					      end
					    end
					    ProviderBreak.where(:service_provider_id => provider.id).order(:start).each do |provider_break|
					      if (provider_break.start.to_datetime - end_time_block)*(start_time_block - provider_break.end.to_datetime) > 0
					        provider_free = false
					      end
					      break if !provider_free
					    end

					    if provider_free
					      status = 'available'
					      available_provider = provider.id
					    end
					  end
					end

					if ['past','available','occupied'].include? status
					  hour = {
					    :start => start_block,
					    :end => end_block
					  }
					end

					block_hour = Hash.new

					block_hour[:date] = @date
					block_hour[:hour] = hour
					block_hour[:service_provider_id] = available_provider

					@available_time << block_hour if status == 'available'
					provider_times_first_open_start = provider_times_first_open_end
				end
			end
		end

		if params[:id] == "0"
			@lock = false
		else
			@lock = true
		end
		@lock
		@company = @location.company
		@available_time
	end

	def available_days
		@service = Service.find(params[:service_id])
		service_duration = @service.duration
		@date = Date.parse(params[:date])
		@location = Location.find(params[:location_id])
		company_setting = CompanySetting.find(Company.find(@location.company_id).company_setting)
		cancelled_id = Status.find_by(name: 'Cancelado').id
		
		if params[:id] == "0"
			# Data
			provider_breaks = ProviderBreak.where(:service_provider_id => @location.service_providers.pluck(:id))
			location_times_first = @location.location_times.order(:open).first
			location_times_final = @location.location_times.order(close: :desc).first

			# Block Hour
			# {
			#   status: 'available/occupied/empty/past',
			#   hour: {
			#     start: '10:00',
			#     end: '10:30',
			#     provider: ''
			#   }
			# }

			@available_days = Array.new(7) { Hash.new }

			(@date.at_beginning_of_week..@date.at_end_of_week).each do |wdate|
				# Variable Data
				day = wdate.cwday
				@available_days[day - 1] = { date: wdate, available: false }
				ordered_providers = ServiceProvider.where(id: @service.service_providers.pluck(:id), location_id: @location.id, active: true, online_booking: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(wdate) }
				location_times = @location.location_times.where(day_id: day).order(:open)

				if location_times.length > 0

					location_times_first_open = location_times_first.open
					location_times_final_close = location_times_final.close

					location_times_first_open_start = location_times_first_open

					while (location_times_first_open_start <=> location_times_final_close) < 0 do

						location_times_first_open_end = location_times_first_open_start + service_duration.minutes

						status = 'empty'
						hour = {
						  :start => '',
						  :end => ''
						}

						open_hour = location_times_first_open_start.hour
						open_min = location_times_first_open_start.min
						start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

						next_open_hour = location_times_first_open_end.hour
						next_open_min = location_times_first_open_end.min
						end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


						start_time_block = DateTime.new(wdate.year, wdate.mon, wdate.mday, open_hour, open_min)
						end_time_block = DateTime.new(wdate.year, wdate.mon, wdate.mday, next_open_hour, next_open_min)
						now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
						before_now = start_time_block - company_setting.before_booking / 24.0
						after_now = now + company_setting.after_booking * 30

						available_provider = ''
						ordered_providers.each do |provider|
						  provider_time_valid = false
						  provider_free = true
						  provider.provider_times.where(day_id: day).each do |provider_time|
						    if (provider_time.open - location_times_first_open_end)*(location_times_first_open_start - provider_time.close) > 0
						    	if provider_time.open <= location_times_first_open_start && provider_time.close >= location_times_first_open_end
			        		provider_time_valid = true
					      	end
						    end
						    break if provider_time_valid
						  end
						  if provider_time_valid
						    if (before_now <=> now) < 1
						      status = 'past'
						    elsif (after_now <=> end_time_block) < 1
						      status = 'past'
						    else
						      status = 'occupied'
						      Booking.where(:service_provider_id => provider.id, :start => wdate.to_time.beginning_of_day..wdate.to_time.end_of_day).each do |provider_booking|
						        unless provider_booking.status_id == cancelled_id
						          if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
						            if !@service.group_service || @service.id != provider_booking.service_id
						              provider_free = false
						              break
						            elsif @service.group_service && @service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => @service.id, :start => start_time_block).count >= @service.capacity
						              provider_free = false
						              break
						            end
						          end
						        end
						      end
						      if @service.resources.count > 0
						        @service.resources.each do |resource|
						          if !@location.resource_locations.pluck(:resource_id).include?(resource.id)
						            provider_free = false
						            break
						          end
						          used_resource = 0
						          group_services = []
						          @location.bookings.where(:start => wdate.to_time.beginning_of_day..wdate.to_time.end_of_day).each do |location_booking|
						            if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
						              if location_booking.service.resources.include?(resource)
						                if !location_booking.service.group_service
						                  used_resource += 1
						                else
						                  if location_booking.service != @service || location_booking.service_provider != provider
						                    group_services.push(location_booking.service_provider.id)
						                  end
						                end
						              end
						            end
						          end
						          if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: @location.id).first.quantity
						            provider_free = false
						            break
						          end
						        end
						      end
						      ProviderBreak.where(:service_provider_id => provider.id).each do |provider_break|
						        if (provider_break.start.to_datetime - end_time_block)*(start_time_block - provider_break.end.to_datetime) > 0
						          provider_free = false
						        end
						        break if !provider_free
						      end
						      if provider_free
						        status = 'available'
						        available_provider = provider.id
						      end
						    end
						    break if ['past','available'].include? status
						  end
						end

						if ['past','available','occupied'].include? status
						  hour = {
						    :start => start_block,
						    :end => end_block,
						  }
						end

						block_hour = Hash.new

						block_hour[:date] = wdate
						block_hour[:hour] = hour
						block_hour[:service_provider_id] = available_provider

						@available_days[day - 1] = { date: wdate, available: true } if status == 'available'
						break if status == 'available'
						location_times_first_open_start = location_times_first_open_start + service_duration.minutes
					end
				end
			end

		else

			# Data
			provider = ServiceProvider.find(params[:id])
			provider_breaks = provider.provider_breaks
			provider_times_first = provider.provider_times.order(:open).first
			provider_times_final = provider.provider_times.order(close: :desc).first

			# Block Hour
			# {
			#   status: 'available/occupied/empty/past',
			#   hour: {
			#     start: '10:00',
			#     end: '10:30',
			#     provider: ''
			#   }
			# }

			@available_days = Array.new

			(@date.at_beginning_of_week..@date.at_end_of_week).each do |wdate|
				# Variable Data
				day = wdate.cwday
				@available_days[day - 1] = { date: wdate, available: false }
				provider_times = provider.provider_times.where(day_id: day).order(:open)

				if provider_times.length > 0

					provider_times_first_open = provider_times_first.open
					provider_times_final_close = provider_times_final.close

					provider_times_first_open_start = provider_times_first_open

					time_offset = 0

					while (provider_times_first_open_start <=> provider_times_final_close) < 0 do

						provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes

						status = 'empty'
						hour = {
						  :start => '',
						  :end => ''
						}

						available_provider = ''
						provider_time_valid = false
						provider_free = true
						provider_times.each do |provider_time|
						if (provider_time.open - provider_times_first_open_end)*(provider_times_first_open_start - provider_time.close) > 0
							if provider_time.open > provider_times_first_open_start
							  time_offset += (provider_time.open - provider_times_first_open_start)/1.minutes
							  if time_offset < service_duration
							    provider_times_first_open_start = provider_time.open
							    provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes
							  end
							end
							if provider_time.open <= provider_times_first_open_start && provider_time.close >= provider_times_first_open_end
							  provider_time_valid = true
							elsif provider_time.open <= provider_times_first_open_start
							  time_offset = time_offset % service_duration
							  provider_times_first_open_start -= time_offset.minutes
							  provider_times_first_open_end -= time_offset.minutes
							  time_offset = 0
							else
							  provider_times_first_open_start -= time_offset.minutes
							  provider_times_first_open_end -= time_offset.minutes
							  time_offset = 0
							end
							end
							break if provider_time_valid
						end

						open_hour = provider_times_first_open_start.hour
						open_min = provider_times_first_open_start.min
						start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

						next_open_hour = provider_times_first_open_end.hour
						next_open_min = provider_times_first_open_end.min
						end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


						start_time_block = DateTime.new(wdate.year, wdate.mon, wdate.mday, open_hour, open_min)
						end_time_block = DateTime.new(wdate.year, wdate.mon, wdate.mday, next_open_hour, next_open_min)
						now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
						before_now = start_time_block - company_setting.before_booking / 24.0
						after_now = now + company_setting.after_booking * 30

						if provider_time_valid
						  if (before_now <=> now) < 1
						    status = 'past'
						  elsif (after_now <=> end_time_block) < 1
						    status = 'past'
						  else
						    status = 'occupied'
						    Booking.where(:service_provider_id => provider.id, :start => wdate.to_time.beginning_of_day..wdate.to_time.end_of_day).each do |provider_booking|
						      unless provider_booking.status_id == cancelled_id
						        if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
						          if !@service.group_service || @service.id != provider_booking.service_id
						            provider_free = false
						            break
						          elsif @service.group_service && @service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => @service.id, :start => start_time_block).count >= @service.capacity
						            provider_free = false
						            break
						          end
						        end
						      end
						    end
						    if @service.resources.count > 0
						      @service.resources.each do |resource|
						        if !@location.resource_locations.pluck(:resource_id).include?(resource.id)
						          provider_free = false
						          break
						        end
						        used_resource = 0
						        group_services = []
						        @location.bookings.where(:start => wdate.to_time.beginning_of_day..wdate.to_time.end_of_day).each do |location_booking|
						          if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
						            if location_booking.service.resources.include?(resource)
						              if !location_booking.service.group_service
						                used_resource += 1
						              else
						                if location_booking.service != @service || location_booking.service_provider != provider
						                  group_services.push(location_booking.service_provider.id)
						                end
						              end
						            end
						          end
						        end
						        if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: @location.id).first.quantity
						          provider_free = false
						          break
						        end
						      end
						    end
						    ProviderBreak.where(:service_provider_id => provider.id).order(:start).each do |provider_break|
						      if (provider_break.start.to_datetime - end_time_block)*(start_time_block - provider_break.end.to_datetime) > 0
						        provider_free = false
						      end
						      break if !provider_free
						    end

						    if provider_free
						      status = 'available'
						      available_provider = provider.id
						    end
						  end
						end

						if ['past','available','occupied'].include? status
						  hour = {
						    :start => start_block,
						    :end => end_block
						  }
						end

						block_hour = Hash.new

						block_hour[:date] = wdate
						block_hour[:hour] = hour
						block_hour[:service_provider_id] = available_provider

						@available_days[day - 1] = { date: wdate, available: true } if status == 'available'
						break if status == 'available'
						provider_times_first_open_start = provider_times_first_open_end
					end
				end
			end
		end

		if params[:id] == "0"
			@lock = false
		else
			@lock = true
		end
		@lock
		@company = @location.company
		@available_time
	end

      private
      
  	  def check_available_hours_params
  	  	if !params[:service_id].present? || !params[:date].present?
          render json: { error: 'Invalid User. Param(s) missing.' }, status: 500
  	  	end
  	  end
  	end
  end
end