class ServiceProvider < ActiveRecord::Base
	belongs_to :location
	belongs_to :company

	has_many :service_staffs, dependent: :destroy
	has_many :services, :through => :service_staffs

	has_many :user_providers, dependent: :destroy
	has_many :users, :through => :user_providers

	has_many :notification_providers, dependent: :destroy
	has_many :notification_emails, :through => :notification_providers

	has_many :provider_times, :inverse_of => :service_provider, dependent: :destroy
	has_many :bookings, dependent: :destroy
	has_many :provider_breaks, dependent: :destroy

	attr_accessor :_destroy

	accepts_nested_attributes_for :provider_times, :reject_if => :all_blank, :allow_destroy => true

	validates :company, :public_name, :location, :presence => true

	validate :time_empty_or_negative, :time_in_location_time, :times_overlap, :outcall_location_provider, :plan_service_providers

	validate :new_plan_service_providers, :on => :create

	def plan_service_providers
		if self.active_changed? && self.active
			if self.company.service_providers.where(active:true).count >= self.company.plan.service_providers
				errors.add(:base, "No se pueden agregar más prestadores con el plan actual, ¡mejóralo!.")
			end
		else
			if self.company.locations.where(active:true).count > self.company.plan.locations
				errors.add(:base, "No se pueden agregar más prestadores con el plan actual, ¡mejóralo!.")
			end
		end
	end

	def new_plan_service_providers
		if self.company.service_providers.where(active:true).count >= self.company.plan.service_providers
			errors.add(:base, "No se pueden agregar más prestadores con el plan actual, ¡mejóralo!.")
		end
	end

	def staff_user
		if self.user && self.user.role_id != Role.find_by_name("Staff")
			errors.add(:base, "El usuario asociado debe ser de tipo staff.")
		end
	end

	def outcall_location_provider
		if self.location.outcall
			notOutcall = false
			self.services.each do |service|
				if service.active
					if !service.outcall
						notOutcall = true
					end
				end
			end
			if notOutcall
				errors.add(:base, "Los servicios asociados a un prestador de una sucursal a domicilio, deben ser exclusivamente servicios a domicilio.")
			end
		end
	end

	def times_overlap
  	self.provider_times.each do |provider_time1|
			self.provider_times.each do |provider_time2|
				if (provider_time1 != provider_time2)
					if(provider_time1.day_id == provider_time2.day_id)
						if (provider_time1.open - provider_time2.close) * (provider_time2.open - provider_time1.close) >= 0
		      		errors.add(:base, "Existen bloques horarios sobrepuestos para el día " + provider_time1.day.name + ".")
				    end
			    end
			   end
			end
		end
	end

	def time_empty_or_negative
		self.provider_times.each do |provider_time|
			if provider_time.open >= provider_time.close
				errors.add(:base, "El horario de término es anterior al de inicio el día " + provider_time.day.name + ".")
      		end
		end
	end

	def time_in_location_time
		self.provider_times.each do |provider_time|
			provider_time_open = provider_time.open.clone()
			provider_time_close = provider_time.close.clone()
			in_location_time = false
			self.location.location_times.each do |location_time|
				if provider_time.day_id == location_time.day_id
					if (provider_time_open.change(:month => 1, :day => 1, :year => 2000) >= location_time.open) && (provider_time_close.change(:month => 1, :day => 1, :year => 2000) <= location_time.close)
						in_location_time = true
					end
				end
			end
			if !in_location_time
				errors.add(:base, "El horario del día " + provider_time.day.name + " no es factible para el local seleccionado.")
			end
		end
	end

	def provider_booking_day_occupation(date)
		available_time = 0.0
		used_time = 0.0
		self.provider_times.each do |provider_time|
			available_time += provider_time.close - provider_time.open
		end
		Booking.where(service_provider_id: self.id, start: date.to_time.beginning_of_day..date.to_time.end_of_day).each do |booking|
			used_time += booking.end - booking.start
		end
		occupation = used_time/available_time
		if occupation > 0
			return occupation
		else
			return 0
		end
	end

	def provider_booking_day_open(date)
		if self.provider_times.where(:day_id => date.cwday).count > 0
			return self.provider_times.find_by_day_id(date.cwday).open
		else
			return DateTime.new(date.year, date.month, date.day, 23, 59, 59)
		end
	end

	def self.available_hours_week_html(service_provider_id, service_id, location_id, start_date)
		week_days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
		require 'date'
	    if service_provider_id == "0"
	      # Data
	      service = Service.find(service_id)
	      service_duration = service.duration
	      weekDate = Date.strptime(start_date, '%Y-%m-%d')
	      local = Location.find(location_id)
	      company_setting = CompanySetting.find(Company.find(local.company_id).company_setting)
	      provider_breaks = ProviderBreak.where(:service_provider_id => local.service_providers.pluck(:id))
	      cancelled_id = Status.find_by(name: 'Cancelado').id
	      location_times_first = local.location_times.order(:open).first
	      location_times_final = local.location_times.order(close: :desc).first

	      @week_blocks = Array.new
	      @days_row = Array.new
	      @days_count = 0
	      # Week Blocks
	      # {
	      #   21-02-2014: [block_hour, block_hour, ...],
	      #   22-02-2014: [block_hour, block_hour, ...]
	      # }

	      weekDate.upto(weekDate + 6) do |date|

	        # Block Hour
	        # {
	        #   status: 'available/occupied/empty/past',
	        #   hour: {
	        #     start: '10:00',
	        #     end: '10:30',
	        #     provider: ''
	        #   }
	        # }

	        available_time = Array.new

	        # Variable Data
	        day = date.cwday
	        ordered_providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(date) }
	        location_times = local.location_times.where(day_id: day).order(:open)

	        # time_offset = 0

	        if location_times.length > 0

	          location_times_first_open = location_times_first.open
	          location_times_final_close = location_times_final.close

	          location_times_first_open_start = location_times_first_open

	          while (location_times_first_open_start <=> location_times_final_close) < 0 do

	            location_times_first_open_end = location_times_first_open_start + service_duration.minutes

	            status = 'hora-vacia'
	            hour = { status: status,
            	start_block: '',
            	end_block: '',
            	available_provider: ''}
	            # hour = '<div class="bloque-hora '+ status +'" data-start data-end data-provider><span></span></div>'

	            open_hour = location_times_first_open_start.hour
	            open_min = location_times_first_open_start.min
	            start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

	            next_open_hour = location_times_first_open_end.hour
	            next_open_min = location_times_first_open_end.min
	            end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


	            start_time_block = DateTime.new(date.year, date.mon, date.mday, open_hour, open_min)
	            end_time_block = DateTime.new(date.year, date.mon, date.mday, next_open_hour, next_open_min)
	            now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
	            before_now = start_time_block - company_setting.before_booking / 24.0
	            after_now = now + company_setting.after_booking * 30

	            promo_discount = 0

	            available_provider = ''
	            ordered_providers.each do |provider|
	              provider_time_valid = false
	              provider_free = true
	              provider.provider_times.where(day_id: day).each do |provider_time|
	                if (provider_time.open - location_times_first_open_end)*(location_times_first_open_start - provider_time.close) > 0
	                  # if provider_time.open > location_times_first_open_start
	                  #   time_offset += (provider_time.open - location_times_first_open_start)/1.minutes
	                  #   if time_offset < service_duration
	                  #     location_times_first_open_start = provider_time.open
	                  #     location_times_first_open_end = location_times_first_open_start + service_duration.minutes
	                  #   end
	                  # end
	                  if provider_time.open <= location_times_first_open_start && provider_time.close >= location_times_first_open_end
	                    provider_time_valid = true
	                  # elsif provider_time.open <= location_times_first_open_start
	                  #   location_times_first_open_start -= time_offset.minutes
	                  #   location_times_first_open_end -= time_offset.minutes
	                  #   time_offset = 0
	                  # else
	                  #   time_offset = time_offset % service_duration
	                  #   location_times_first_open_start -= time_offset.minutes
	                  #   location_times_first_open_end -= time_offset.minutes
	                  #   time_offset = 0
	                  end
	                end
	                break if provider_time_valid
	              end
	              if provider_time_valid
	                if (before_now <=> now) < 1
	                  status = 'hora-pasada'
	                elsif (after_now <=> end_time_block) < 1
	                  status = 'hora-pasada'
	                else
	                  status = 'hora-ocupada'
	                  Booking.where(:service_provider_id => provider.id, :start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |provider_booking|
	                    unless provider_booking.status_id == cancelled_id
	                      if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
	                        if !service.group_service || service.id != provider_booking.service_id
	                        	if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
		                          provider_free = false
		                          break
		                        end
	                        elsif service.group_service && service.id == provider_booking.service_id && provider.bookings.where(:service_id => service.id, :start => start_time_block).where.not(status_id: Status.find_by_name('Cancelado')).count >= service.capacity
	                        	if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
		                          	provider_free = false
		                         	break
		                        end
	                        end
	                      end
	                    end
	                  end
	                  if service.resources.count > 0
	                    service.resources.each do |resource|
	                      if !local.resource_locations.pluck(:resource_id).include?(resource.id)
	                        provider_free = false
	                        break
	                      end
	                      used_resource = 0
	                      group_services = []
	                      local.bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |location_booking|
	                        if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
	                          if location_booking.service.resources.include?(resource)
	                            if !location_booking.service.group_service
	                              used_resource += 1
	                            else
	                              if location_booking.service != service || location_booking.service_provider != provider
	                                group_services.push(location_booking.service_provider.id)
	                              end
	                            end
	                          end
	                        end
	                      end
	                      if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: local.id).first.quantity
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
	                    status = 'hora-disponible'
	                    available_provider = provider.id

	                    #Check for existing promotions
	                    if service.has_time_discount
	                    	promo_time = provider.company.company_setting.promo_time
	                    	service_promo = ServicePromo.find(service.active_service_promo_id)
	                    	if !promo_time.nil? && !service_promo.nil?
	                    		if Promo.where(:service_promo_id => service_promo.id, :day_id => day, :location_id => local.id).count > 0

			                    	promo = Promo.where(:service_promo_id => service_promo.id, :day_id => day, :location_id => local.id).first

		                    		if !(service_promo.morning_end.strftime("%H:%M") <= start_time_block.strftime("%H:%M") || end_time_block.strftime("%H:%M") <= service_promo.morning_start.strftime("%H:%M"))
				                    		
				                    	status = 'hora-promocion'
				                    	promo_discount = promo.morning_discount

				                    elsif !(service_promo.afternoon_end.strftime("%H:%M") <= start_time_block.strftime("%H:%M") || end_time_block.strftime("%H:%M") <= service_promo.afternoon_start.strftime("%H:%M"))

				                    	status = 'hora-promocion'
				                    	promo_discount = promo.afternoon_discount

				                    elsif !(service_promo.night_end.strftime("%H:%M") <= start_time_block.strftime("%H:%M") || end_time_block.strftime("%H:%M") <= service_promo.night_start.strftime("%H:%M"))

				                    	status = 'hora-promocion'
				                    	promo_discount = promo.night_discount

				                    end

				                end
				            end
	                    end

	                    #Check for last minute promotion


	                  end
	                end
	                break if ['hora-pasada','hora-disponible', 'hora-promocion'].include? status
	              end
	            end

	            if ['hora-pasada','hora-disponible','hora-ocupada', 'hora-promocion'].include? status
	            	hour = { status: status,
	            	start_block: start_block,
	            	end_block: end_block,
	            	available_provider: available_provider.to_s,
	            	promo_discount: promo_discount.to_s}
	            	# hour = '<div class="bloque-hora '+ status +'" data-start="'+ start_block +'" data-end="'+ end_block +'" data-provider="' + available_provider.to_s + '"><span>'+ start_block +' - '+ end_block +'</span></div>'
	            end

	            available_time << hour
	            location_times_first_open_start = location_times_first_open_start + service_duration.minutes
	          end
	          if available_time.count > 0
	          	@days_count += 1
      			@week_blocks << { available_time: available_time, formatted_date: date.strftime('%Y-%m-%d') }
      			@days_row << { day_name: week_days[date.wday], day_number: date.strftime("%e")}
	          end
	        end
	      end

	    else
	    	#There is a provider given
	      # Data
	      promo_discount = 0
	      service = Service.find(service_id)
	      service_duration = service.duration
	      weekDate = Date.strptime(start_date, '%Y-%m-%d')
	      local = Location.find(location_id)
	      company_setting = CompanySetting.find(Company.find(local.company_id).company_setting)
	      provider = ServiceProvider.find(service_provider_id)
	      provider_breaks = provider.provider_breaks
	      cancelled_id = Status.find_by(name: 'Cancelado').id
	      provider_times_first = provider.provider_times.order(:open).first
	      provider_times_final = provider.provider_times.order(close: :desc).first

	      @week_blocks = Array.new
	      @days_row = Array.new
	      @days_count = 0
	      # Week Blocks
	      # {
	      #   21-02-2014: [block_hour, block_hour, ...],
	      #   22-02-2014: [block_hour, block_hour, ...]
	      # }

	      weekDate.upto(weekDate + 6) do |date|
	        # Block Hour
	        # {
	        #   status: 'available/occupied/empty/past',
	        #   hour: {
	        #     start: '10:00',
	        #     end: '10:30',
	        #     provider: ''
	        #   }
	        # }

	        available_time = Array.new

	        # Variable Data
	        day = date.cwday
	        provider_times = provider.provider_times.where(day_id: day).order(:open)

	        if provider_times.length > 0

	          provider_times_first_open = provider_times_first.open
	          provider_times_final_close = provider_times_final.close

	          provider_times_first_open_start = provider_times_first_open

	          time_offset = 0

	          while (provider_times_first_open_start <=> provider_times_final_close) < 0 do

	            provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes

	            status = 'hora-vacia'
	            hour = { status: status,
            	start_block: '',
            	end_block: '',
            	available_provider: '',
            	promo_discount: '0'}
	            # hour = '<div class="bloque-hora '+ status +'" data-start data-end data-provider><span></span></div>'

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

	            promo_discount = 0

	            start_time_block = DateTime.new(date.year, date.mon, date.mday, open_hour, open_min)
	            end_time_block = DateTime.new(date.year, date.mon, date.mday, next_open_hour, next_open_min)
	            now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
	            before_now = start_time_block - company_setting.before_booking / 24.0
	            after_now = now + company_setting.after_booking * 30

	            if provider_time_valid
	              if (before_now <=> now) < 1
	                status = 'hora-pasada'
	              elsif (after_now <=> end_time_block) < 1
	                status = 'hora-pasada'
	              else
	                status = 'hora-ocupada'
	                Booking.where(:service_provider_id => provider.id, :start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |provider_booking|
	                  unless provider_booking.status_id == cancelled_id
	                    if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
	                      if !service.group_service || service.id != provider_booking.service_id
	                      	if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
		                        provider_free = false
		                        break
		                    end
	                      elsif service.group_service && service.id == provider_booking.service_id && provider.bookings.where(:service_id => service.id, :start => start_time_block).where.not(status_id: Status.find_by_name('Cancelado')).count >= service.capacity
	                      	if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
		                        provider_free = false
		                        break
		                    end
	                      end
	                    end
	                  end
	                end
	                if service.resources.count > 0
	                  service.resources.each do |resource|
	                    if !local.resource_locations.pluck(:resource_id).include?(resource.id)
	                      provider_free = false
	                      break
	                    end
	                    used_resource = 0
	                    group_services = []
	                    local.bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |location_booking|
	                      if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
	                        if location_booking.service.resources.include?(resource)
	                          if !location_booking.service.group_service
	                            used_resource += 1
	                          else
	                            if location_booking.service != service || location_booking.service_provider != provider
	                              group_services.push(location_booking.service_provider.id)
	                            end
	                          end
	                        end
	                      end
	                    end
	                    if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: local.id).first.quantity
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
	                  status = 'hora-disponible'
	                  available_provider = provider.id

	                  #Check for existing promotions
                    if service.has_time_discount
                    	promo_time = provider.company.company_setting.promo_time
                    	if !promo_time.nil?
                    		service_promo = ServicePromo.find(service.active_service_promo_id)

                    		if !service_promo.nil?
	                    		if Promo.where(:service_promo_id => service_promo.id, :day_id => day, :location_id => local.id).count > 0

			                    	promo = Promo.where(:service_promo_id => service_promo.id, :day_id => day, :location_id => local.id).first

		                    		if !(promo_time.morning_end.strftime("%H:%M") <= start_time_block.strftime("%H:%M") || end_time_block.strftime("%H:%M") <= promo_time.morning_start.strftime("%H:%M"))
					                    		
				                    	status = 'hora-promocion'
				                    	promo_discount = promo.morning_discount

				                    elsif !(promo_time.afternoon_end.strftime("%H:%M") <= start_time_block.strftime("%H:%M") || end_time_block.strftime("%H:%M") <= promo_time.afternoon_start.strftime("%H:%M"))

				                    	status = 'hora-promocion'
				                    	promo_discount = promo.afternoon_discount

				                    elsif !(promo_time.night_end.strftime("%H:%M") <= start_time_block.strftime("%H:%M") || end_time_block.strftime("%H:%M") <= promo_time.night_start.strftime("%H:%M"))

				                    	status = 'hora-promocion'
				                    	promo_discount = promo.night_discount

				                    end

				                end
				            end
			            end
                    end

                    #Check for last minute promotion


	                end
	              end
	            end

	            if ['hora-pasada','hora-disponible','hora-ocupada', 'hora-promocion'].include? status
	            	hour = { status: status,
	            	start_block: start_block,
	            	end_block: end_block,
	            	available_provider: available_provider.to_s,
	            	promo_discount: promo_discount.to_s}
	            	# hour = '<div class="bloque-hora '+ status +'" data-start="'+ start_block +'" data-end="'+ end_block +'" data-provider="' + available_provider.to_s + '"><span>'+ start_block +' - '+ end_block +'</span></div>'
	            end

	            available_time << hour
	            provider_times_first_open_start = provider_times_first_open_end
	          end
	          if available_time.count > 0
	          	@days_count += 1
      			@week_blocks << { available_time: available_time, formatted_date: date.strftime('%Y-%m-%d') }
      			@days_row << { day_name: week_days[date.wday], day_number: date.strftime("%e")}
	          end
	        end
	      end
	    end

	    week_blocks = ''
	    days_row = ''
	    width = ( 100.0 / @days_count ).round(2).to_s

	    @week_blocks.each do |week_block|
	    	week_blocks += '<div class="columna-dia" data-date="' + week_block[:formatted_date] + '" style="width: ' + width + '%;">'
	    	week_block[:available_time].each do |hour|

	    		logger.info hour.inspect

	    		if hour[:status] != "hora-promocion"
	    			week_blocks += '<div class="bloque-hora ' + hour[:status] + '" data-start="' + hour[:start_block] + '" data-end="' + hour[:end_block] + '" data-provider="' + hour[:available_provider] + '" data-discount="' + hour[:promo_discount] + '"><span>' + hour[:start_block] + ' - ' + hour[:end_block] + '</span></div>'
	    		else
	    			week_blocks += '<div class="bloque-hora ' + hour[:status] + '" data-start="' + hour[:start_block] + '" data-end="' + hour[:end_block] + '" data-provider="' + hour[:available_provider] + '" data-discount="' + hour[:promo_discount] + '"><span>' + ActionController::Base.helpers.image_tag('admin/icono_promociones.png', class: 'promotion-hour-icon', size: "18x18") + '&nbsp;&nbsp' + hour[:start_block] + ' - ' + hour[:end_block] + '</span></div>'
	    		end
	    	end
	    	week_blocks += '<div class="clear"></div></div>'
	    end
	    week_blocks += '<div class="clear"></div>'

	    @days_row.each do |day|
	    	days_row += '<div class="dia-semana" style="width: ' + width + '%;">' + day[:day_name] + ' ' + day[:day_number] + '</div>'
	    end

	    days_count = @days_count

	    return { panel_body: week_blocks, days_row: days_row, days_count: days_count }
	end
end
