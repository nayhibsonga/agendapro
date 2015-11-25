class Service < ActiveRecord::Base
	require 'pg_search'
	include PgSearch

	belongs_to :company
	belongs_to :service_category

	has_many :service_tags, dependent: :destroy
	has_many :tags, :through => :service_tags

	has_many :service_resources, dependent: :destroy
  	has_many :resources, :through => :service_resources

	has_many :bookings, dependent: :destroy
	has_many :service_staffs, dependent: :destroy
	has_many :service_providers, :through => :service_staffs

	has_many :service_promos
	has_many :last_minute_promos

	has_many :economic_sectors, :through => :company
  	has_many :economic_sectors_dictionaries, :through => :economic_sectors

  	has_many :mock_bookings

  	has_many :service_commissions

	mount_uploader :time_promo_photo, TimePromoPhotoUploader

	scope :with_time_promotions, -> { where(has_time_discount: true, active: true, online_payable: true, online_booking: true, time_promo_active: true).where.not(:active_service_promo_id => nil) }
	scope :with_last_minute_promotions, -> { where(has_last_minute_discount: true, active: true, online_payable: true, online_booking: true)}

	accepts_nested_attributes_for :service_category, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :duration, :company, :service_category, :presence => true
	validates :duration, numericality: { greater_than_or_equal_to: 5, :less_than_or_equal_to => 1439 }
	validates :price, numericality: { greater_than_or_equal_to: 0 }

	validate :group_service_capacity, :outcall_providers

	pg_search_scope :search, 
	:against => :name,
	:associated_against => {
		:service_category => :name,
		:economic_sectors => :name,
    	:economic_sectors_dictionaries => :name
	},
	:using => {
                :trigram => {
                  	:threshold => 0.1,
                  	:prefix => true,
                	:any_word => true
                },
                :tsearch => {
                	:prefix => true,
                	:any_word => true
                }
    },
    :ignoring => :accents

    def active_service_promo
    	if self.active_service_promo_id.nil?
    		return nil
    	else
    		return ServicePromo.find(self.active_service_promo_id)
    	end
    end

	def group_service_capacity
		if self.group_service
			if !self.capacity || self.capacity < 1
				errors.add(:base, "Un servicio de grupo debe tener capacidad.")
			end
		end
	end

	def outcall_providers
		if !self.outcall
			outcall = false
			self.service_providers.each do |service_provider|
				if service_provider.active
					if service_provider.location.outcall
						outcall = true
					end
				end
			end
			if outcall
				errors.add(:base, "Un servicio no a domicilio no puede estar asociado a un local a domicilio.")
			end
		end
	end

	def name_with_small_outcall
		outcallString = ''
		if self.outcall
			outcallString = '<br /><small>(a domicilio)</small>'
		end
		self.name << outcallString
		self.name.html_safe
	end

	def get_max_time_discount

		discount = 0

		if self.has_time_discount && !self.active_service_promo_id.nil?
			
			service_promo = ServicePromo.find(self.active_service_promo_id)
			service_promo.promos.each do |promo|
				if promo.morning_discount > discount
					discount = promo.morning_discount
				end
				if promo.afternoon_discount > discount
					discount = promo.afternoon_discount
				end
				if promo.night_discount > discount
					discount = promo.night_discount
				end
			end

		end

		return discount

	end

	def active_promo_max
		if self.active_service_promo_id.nil?
			return 0
		else
			service_promo = ServicePromo.find(self.active_service_promo_id)
			return service_promo.max_bookings
		end
	end

	def active_promo_left_bookings

		if self.active_service_promo_id.nil?

			return 0

		else

			service_promo = ServicePromo.find(self.active_service_promo_id)

			if service_promo.max_bookings.nil?
				service_promo.max_bookings = 0
				service_promo.save
				return 0
			end

			return service_promo.max_bookings

		end

	end

	def get_last_minute_hours(location_id)
		if !self.has_last_minute_discount
			return 0
		else
			promo = LastMinutePromo.where(:service_id => self.id, :location_id => location_id).first
			return promo.hours
		end
	end

	def get_last_minute_discount(location_id)
		if !self.has_last_minute_discount
			return 0
		else
			promo = LastMinutePromo.where(:service_id => self.id, :location_id => location_id).first
			return promo.discount
		end
	end

	# def get_last_minute_available_hours(provider_id, location_id, day_id)

	# 	available_hours = []

	# 	location = Location.find(location_id)

	# 	last_minute_hours = self.get_last_minute_hours(location_id)

	# 	now = DateTime.now
	# 	now_m = now.min

	# 	if self.duration < 60
	# 		if now_m < self.duration
	# 			now = now + (self.duration - now_m).minutes + self.duration.minutes
	# 		else
	# 			now = now + 1.hours
	# 			now = now - now_m.minutes
	# 			now = now + self.duration.minutes
	# 		end
	# 	else
	# 		now = now + 2.hours
	# 		now = now - now_m.minutes
	# 	end

	# 	day = now.cwday

	# 	open_time = location.location_times.where(day_id: day).order(:open).first.open
	# 	close_time = location.location_times.where(day_id: day).order(:close).first.close

	# 	dateTimePointer = DateTime.new(now.year, now.mon, now.mday, now.hour, now.min)
	# 	open = DateTime.new(now.year, now.mon, now.mday, open_time.hour, open_time.min)
	# 	close = DateTime.new(now.year, now.mon, now.mday, close_time.hour, close_time.min)

	# 	cancelled_id = Status.find_by_name('Cancelado').id

	# 	limit = DateTime.now + last_minute_hours.hours
	# 	#limit = DateTime.new(limit.year, limit.mon, limit.mday, limit.hour, limit.min)

	# 	puts "Times: "
	# 	puts "DTP: " + dateTimePointer.to_s
	# 	puts "Open: " + open.to_s
	# 	puts "Close: " + close.to_s
	# 	puts "Limit: " + limit.to_s	

	# 	total_services_duration = 0

	#     #False if last tried block allocation failed.
	#     #Used for searching gaps. They should be looked for only if last block culd be allocated,
	#     #because if not, then there isn't anyway that coming back in time cause correct allocation.
	#     last_check = false

	#     #Checks if the block being allocated is from a gap
	#     is_gap_hour = false

	#     #Holds current_gap to sum a day's total gap and adjust calendar's height
	#     current_gap = 0

 #      	day_open_time = dateTimePointer

 #      	dateTimePointerEnd = dateTimePointer

	# 	if provider_id.nil? || provider_id == "0" || provider_id == 0
			
	# 		puts "Sin preferencia"

	# 		while dateTimePointer < limit
				
	# 			min_pt = ProviderTime.where(:service_provider_id => ServiceProvider.where(active: true, online_booking: true, :location_id => local.id, :id => ServiceStaff.where(:service_id => self.id).pluck(:service_provider_id)).pluck(:id)).where(day_id: day).order(:open).first

	# 	        # logger.debug "MIN PROVIDER TIME: " + min_pt.open.strftime("%H:%M")
	# 	        # logger.debug "DATE TIME POINTER: " + dateTimePointer.strftime("%H:%M")

	# 	        if !min_pt.nil? && min_pt.open.strftime("%H:%M") > dateTimePointer.strftime("%H:%M")
	# 	            #logger.debug "Changing dtp"
	# 	            dateTimePointer = min_pt.open
	# 	            dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
	# 	            day_open_time = dateTimePointer
	# 	        end

	# 	        #Uncomment for overlaping hours
          
	# 	        if !self.company.company_setting.allows_optimization && last_check
	# 	        	dateTimePointer = dateTimePointer - self.duration.minutes + first_service.company.company_setting.calendar_duration.minutes
	# 	        end

	# 	        if !self.company.company_setting.allows_optimization
	# 	            #Calculate offset
	# 	            offset_diff = (dateTimePointer-day_open_time)*24*60
	# 	            offset_rem = offset_diff % self.company.company_setting.calendar_duration
	# 	            if offset_rem != 0
	# 	              dateTimePointer = dateTimePointer + (self.company.company_setting.calendar_duration - offset_rem).minutes
	# 	            end
	# 	        end

	# 			self.service_providers.where(active: true).each do |service_provider|

	# 				provider_time = service_provider.provider_times.where(day_id: day).first

	# 				provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
	#               	provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

	#               	#Check provider times
	#               	if provider_open > dateTimePointer || provider_close < (dateTimePointer + self.duration.minutes)
	#               		service_valid = false
	#               		break
	#               	else
	#               		service_valid = true
	#               	end

	#               	#Check provider breaks
	# 	            if service_valid
	# 	              	#service_provider.provider_breaks.each do |provider_break|
	# 	                #	if !(provider_break.end.to_datetime <= dateTimePointer || (dateTimePointer + self.duration.minutes) <= provider_break.start.to_datetime)
	# 	                #  		service_valid = false
	# 	                #  		break
	# 	                #	end
	# 	              	#end
	# 	              	if service_provider.provider_breaks.where.not('(provider_breaks.end <= ? or ? <= provider_breaks.start)', dateTimePointer, dateTimePointer + self.duration.minutes).count > 0
 #                  			service_valid = false
 #                  			break
 #                		end
	# 	            end

	# 	            # Cross Booking
	# 	            if service_valid
		              
	# 	            	if !self.group_service
	# 	                  if Booking.where(service_provider_id: service_provider.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + self.duration.minutes).count > 0
	# 	                    service_valid = false
	# 	                    break
	# 	                  end
	# 	                else
	# 	                	if Booking.where(service_provider_id: service_provider.id).where.not(service_id: self.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + self.duration.minutes).count > 0
	# 	                    	service_valid = false
	# 	                    	break
	# 	                  	end
	# 	                  	if Booking.where(service_provider_id: service_provider.id, service_id: self.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + self.duration.minutes).count >= self.capacity
	# 	                    	service_valid = false
	# 	                    	break
	# 	                  	end
	# 	                end

	# 	            end


	# 	            # Recursos
	# 	            if service_valid and self.resources.count > 0
	# 	              	service.resources.each do |resource|
	# 	                  if !location.resource_locations.pluck(:resource_id).include?(resource.id)
	# 	                    service_valid = false
	# 	                    break
	# 	                  end
	# 	                  used_resource = 0
	# 	                  group_services = []
	# 	                  pointerEnd = dateTimePointer+service.duration.minutes
	# 	                  location.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
	# 	                    if location_booking.status_id != cancelled_id && !(pointerEnd <= location_booking.start.to_datetime || location_booking.end.to_datetime <= dateTimePointer)
	# 	                      if location_booking.service.resources.include?(resource)
	# 	                        if !location_booking.service.group_service
	# 	                          used_resource += 1
	# 	                        else
	# 	                          if location_booking.service != service || location_booking.service_provider != service_provider
	# 	                            group_services.push(location_booking.service_provider.id)
	# 	                          end
	# 	                        end
	# 	                      end
	# 	                    end
	# 	                  end
	# 	                  if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: location.id).first.quantity
	# 	                    service_valid = false
	# 	                    break
	# 	                  end
	# 	                end
	# 	            end

	# 	            if service_valid

	# 	              available_hours << {
	# 	                :service => self.id,
	# 	                :provider => service_provider.id,
	# 	                :start => dateTimePointer,
	# 	                :end => dateTimePointer + self.duration.minutes,
	# 	                :service_name => self.name,
	# 	                :provider_name => service_provider.public_name,
	# 	                :provider_lock => true
	# 	              }
	# 	              dateTimePointer += self.duration.minutes
	# 	              break #Break providers loop
	# 	            end

	# 	        end

	# 		end


	# 	else

	# 		service_provider = ServiceProvider.find(provider_id)

	# 		puts service_provider.public_name

	# 		while dateTimePointer < limit && dateTimePointer < close
				
	# 			service_valid = false

	# 			#Check dtp + duration isn't out of location time
	# 			if (dateTimePointer + self.duration.minutes) > close
	# 				service_valid = false
	# 				puts "Break 1"
	# 				puts (dateTimePointer + self.duration.minutes).to_s
	# 				puts close.to_s
	# 				break
	# 			else
	# 				service_valid = true
	# 			end

	# 			puts "Service valid 1"

	# 			provider_time = service_provider.provider_times.where(day_id: day).first

	# 			provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
 #              	provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

 #              	#Check provider times
 #              	if provider_open > dateTimePointer || provider_close < (dateTimePointer + self.duration.minutes)
 #              		service_valid = false
 #              		break
 #              	else
 #              		service_valid = true
 #              	end

 #              	puts "Service valid 2"

 #              	#Check provider breaks
	#             if service_valid
	#               	if service_provider.provider_breaks.where.not('(provider_breaks.end <= ? or ? <= provider_breaks.start)', dateTimePointer, dateTimePointer + self.duration.minutes).count > 0
 #                  		service_valid = false
 #                  		break
 #                	end
	#             end

 #              	puts "Service valid 3"


	#             # Cross Booking
	#             if service_valid
	#               	if !self.group_service
	# 	                if Booking.where(service_provider_id: service_provider.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + self.duration.minutes).count > 0
	# 	                   	service_valid = false
	# 	                    break
	# 	                end
	# 	            else

	# 	            	if Booking.where(service_provider_id: service_provider.id).where.not(service_id: self.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + self.duration.minutes).count > 0
	# 	                   	service_valid = false
	# 	                    break
	# 	                end

	# 	                if Booking.where(service_provider_id: service_provider.id, service_id: self.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + self.duration.minutes).count >= self.capacity
	# 	                    service_valid = false
	# 	                    break
	# 	                end
	# 	            end
	#             end

	#             puts "Service valid 4"


	#             # Recursos
	#             if service_valid and self.resources.count > 0
	#               	self.resources.each do |resource|
	#                   if !location.resource_locations.pluck(:resource_id).include?(resource.id)
	#                     service_valid = false
	#                     break
	#                   end
	#                   used_resource = 0
	#                   group_services = []
	#                   pointerEnd = dateTimePointer+service.duration.minutes
	#                   location.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
	#                     if location_booking.status_id != cancelled_id && !(pointerEnd <= location_booking.start.to_datetime || location_booking.end.to_datetime <= dateTimePointer)
	#                       if location_booking.service.resources.include?(resource)
	#                         if !location_booking.service.group_service
	#                           used_resource += 1
	#                         else
	#                           if location_booking.service != service || location_booking.service_provider != service_provider
	#                             group_services.push(location_booking.service_provider.id)
	#                           end
	#                         end
	#                       end
	#                     end
	#                   end
	#                   if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: location.id).first.quantity
	#                     service_valid = false
	#                     break
	#                   end
	#                	end
	#             end

	#             puts "Service valid 5"

	#             if service_valid

	#               available_hours << {
	#                 :service => self.id,
	#                 :provider => service_provider.id,
	#                 :start => dateTimePointer,
	#                 :end => dateTimePointer + self.duration.minutes,
	#                 :service_name => self.name,
	#                 :provider_name => service_provider.public_name,
	#                 :provider_lock => true
	#               }
	#             end

	#             dateTimePointer += self.duration.minutes

	# 		end

	# 	end

	# 	return available_hours

	# end

	def self.get_last_minute_available_hours(location, serviceStaffArr, datepicker)

		require 'date'

	    local = Location.find(location)
	    company_setting = local.company.company_setting
	    cancelled_id = Status.find_by(name: 'Cancelado').id
	    serviceStaff = serviceStaffArr
	    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
	    session_booking = nil

	    #if params[:session_booking_id] && params[:session_booking_id] != ""
	    #  session_booking = SessionBooking.find(params[:session_booking_id])
	    #end

	    if @is_session_booking
	    	session_booking = @booking.session_booking
	    end


	    if datepicker and datepicker != ""
	      if datepicker.to_datetime > now
	        now = datepicker.to_datetime
	      end
	    end

	    date = now
	    @date = Date.parse(datepicker)

	    #logger.debug "now: " + now.to_s

	    days_ids = [1,2,3,4,5,6,7]
	    index = days_ids.find_index(now.cwday)
	    ordered_days = days_ids[index, days_ids.length] + days_ids[0, index]

	    book_index = 0
	    book_summaries = []

	    total_hours_array = []

	    loop_times = 0

	    max_time_diff = 0

	    #Save first service and it's providers for later use

	    first_service = Service.find(serviceStaff[0][:service])
	    first_providers = []
	    if serviceStaff[0][:provider] != "0"
	      first_providers << ServiceProvider.find(serviceStaff[0][:provider])
	    else
	      first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(:order, :public_name)
	    end

	    #Look for services and providers and save them for later use.
	    #Also, save total services duration

	    total_services_duration = 0

	    #False if last tried block allocation failed.
	    #Used for searching gaps. They should be looked for only if last block culd be allocated,
	    #because if not, then there isn't anyway that coming back in time cause correct allocation.
	    last_check = false

	    #Checks if the block being allocated is from a gap
	    is_gap_hour = false

	    #Holds current_gap to sum a day's total gap and adjust calendar's height
	    current_gap = 0

	    services_arr = []
	    providers_arr = []
	    for i in 0..serviceStaff.length-1
	      services_arr[i] = Service.find(serviceStaff[i][:service])
	      total_services_duration += services_arr[i].duration
	      if serviceStaff[i][:provider] != "0"
	        providers_arr[i] = []
	        providers_arr[i] << ServiceProvider.find(serviceStaff[i][:provider])
	      else
	        providers_arr[i] = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true)
	      end
	    end

	    #providers_arr = []
	    #for i
	    hours_array = []

	    after_date = DateTime.now + company_setting.after_booking.months

	    day = now.cwday
		dtp = local.location_times.where(day_id: day).order(:open).first

		logger.debug "Reaches 1"

		if dtp.nil?
			if serviceStaff[0][:provider] == "0"
		    	@lock = false
		    else
		    	@lock = true
		    end

		    @lock
		    @company = local.company
		    @location = local
		    @serviceStaff = serviceStaff
		    @date = Date.parse(datepicker)
		    @service = Service.find(serviceStaff[0][:service])

		    @available_time = hours_array
		    @bookSummaries = book_summaries
			return
		end

		logger.debug "Reaches 2"

		dateTimePointer = dtp.open

		dateTimePointer = DateTime.new(now.year, now.mon, now.mday, dateTimePointer.hour, dateTimePointer.min)
		day_open_time = dateTimePointer

		dateTimePointerEnd = dateTimePointer


		if now > after_date
			if serviceStaff[0][:provider] == "0"
		    	@lock = false
		    else
		    	@lock = true
		    end

		    @lock
		    @company = local.company
		    @location = local
		    @serviceStaff = serviceStaff
		    @date = Date.parse(datepicker)
		    @service = Service.find(serviceStaff[0][:service])

		    @available_time = hours_array
		    @bookSummaries = book_summaries
			return
		end


		day_close = local.location_times.where(day_id: day).order(:close).first.close
		limit_date = DateTime.new(now.year, now.mon, now.mday, day_close.hour, day_close.min)

		while (dateTimePointer < limit_date)

			logger.debug "***"
			logger.debug "***"
			logger.debug "DTP is: " + dateTimePointer.to_s
			logger.debug "***"
			logger.debug "***"

			serviceStaffPos = 0
			bookings = []

			while serviceStaffPos < serviceStaff.length and (dateTimePointer < limit_date)

				logger.debug "***"
				logger.debug "***"
				logger.debug "DTP is: " + dateTimePointer.to_s
				logger.debug "***"
				logger.debug "***"

				serviceStaffPos = 0
				bookings = []

			  service_valid = true
			  service = services_arr[serviceStaffPos]

			  #Get providers min
			  min_pt = ProviderTime.where(:service_provider_id => ServiceProvider.where(active: true, online_booking: true, :location_id => local.id, :id => ServiceStaff.where(:service_id => service.id).pluck(:service_provider_id)).pluck(:id)).where(day_id: day).order(:open).first

			  if !min_pt.nil? && min_pt.open.strftime("%H:%M") > dateTimePointer.strftime("%H:%M")
			    dateTimePointer = min_pt.open
			    dateTimePointer = DateTime.new(now.year, now.mon, now.mday, dateTimePointer.hour, dateTimePointer.min)
			    day_open_time = dateTimePointer
			  end

			  #To deattach continous services, just delete the serviceStaffPos condition

			  if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization && last_check
	            dateTimePointer = dateTimePointer - total_services_duration.minutes + first_service.company.company_setting.calendar_duration.minutes
	          end

			  if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization
			    #Calculate offset
			    offset_diff = (dateTimePointer-day_open_time)*24*60
			    offset_rem = offset_diff % first_service.company.company_setting.calendar_duration
			    if offset_rem != 0
			      dateTimePointer = dateTimePointer + (first_service.company.company_setting.calendar_duration - offset_rem).minutes
			    end
			  end

			  #Find next service block starting from dateTimePointer
			  service_sum = service.duration.minutes

			  if service_valid
			    service_valid = false
			    local.location_times.where(day_id: dateTimePointer.cwday).each do |times|
			      location_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.open.hour, times.open.min)
			      location_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.close.hour, times.close.min)

			      logger.debug "***"
					logger.debug "***"
					logger.debug "location open: " + location_open.to_s
					logger.debug "***"
					logger.debug "***"

					logger.debug "***"
					logger.debug "***"
					logger.debug "location open: " + location_close.to_s
					logger.debug "***"
					logger.debug "***"

					logger.debug "***"
					logger.debug "***"
					logger.debug "DTP is: " + dateTimePointer.to_s
					logger.debug "***"
					logger.debug "***"

			      if location_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= location_close
			        service_valid = true
			        break
			      end
			    end
			  end

			  	logger.debug "***"
				logger.debug "***"
				logger.debug "Reaches before providers loop"
				logger.debug "***"
				logger.debug "***"

				logger.debug "***"
				logger.debug "***"
				logger.debug "Service valid: " + service_valid.to_s
				logger.debug "***"
				logger.debug "***"

			  # Horario dentro del horario del provider
				if service_valid
					providers = []
					if serviceStaff[serviceStaffPos][:provider] != "0"
					  providers = providers_arr[serviceStaffPos]
					else

					  #Check if providers have same day open
					  #If they do, choose the one with less ocupations to start with
					  #If they don't, choose the one that starts earlier.
					  if service.check_providers_day_times(dateTimePointer)

					    providers = providers_arr[serviceStaffPos].order(:order, :public_name).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }

					  else

					    providers = providers_arr[serviceStaffPos].order(:order, :public_name).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }
					  end



					end

					providers.each do |provider|

					  provider_min_pt = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first
					  if !provider_min_pt.nil? && dateTimePointer.strftime("%H:%M") < provider_min_pt.open.strftime("%H:%M")
					    dateTimePointer = provider_min_pt.open
					    dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
					  end

					  service_valid = false

					  #Check directly on query instead of looping through

					  logger.debug "***"
						logger.debug "***"
						logger.debug "Reaches before provider times"
						logger.debug "***"
						logger.debug "***"

					  provider.provider_times.where(day_id: dateTimePointer.cwday).each do |provider_time|
					    provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
					    provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

					    if provider_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= provider_close
					      service_valid = true
					      break
					    end
					  end

					  logger.debug "***"
						logger.debug "***"
						logger.debug "Reaches before provider breaks"
						logger.debug "***"
						logger.debug "***"

					  # Provider breaks
					  if service_valid

					    if provider.provider_breaks.where.not('(provider_breaks.end <= ? or ? <= provider_breaks.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
					      service_valid = false
					    end

					  end

					  logger.debug "***"
						logger.debug "***"
						logger.debug "Reaches before cross bookings"
						logger.debug "***"
						logger.debug "***"

					  # Cross Booking
					  if service_valid

					    if !service.group_service
					      if Booking.where(service_provider_id: provider.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
					        service_valid = false
					      end
					    else
					      if Booking.where(service_provider_id: provider.id, service_id: service.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count >= service.capacity
					        service_valid = false
					      end
					    end

					  end

					  logger.debug "***"
						logger.debug "***"
						logger.debug "Reaches before resources"
						logger.debug "***"
						logger.debug "***"

					  # Recursos
					  if service_valid and service.resources.count > 0
					    service.resources.each do |resource|
					      if !local.resource_locations.pluck(:resource_id).include?(resource.id)
					        service_valid = false
					        break
					      end
					      used_resource = 0
					      group_services = []
					      pointerEnd = dateTimePointer+service.duration.minutes
					      local.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
					        if location_booking.status_id != cancelled_id && !(pointerEnd <= location_booking.start.to_datetime || location_booking.end.to_datetime <= dateTimePointer)
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
					        service_valid = false
					        break
					      end
					    end
					  end

					  logger.debug "***"
						logger.debug "***"
						logger.debug "Reaches before validity check"
						logger.debug "***"
						logger.debug "***"

					  if service_valid

					    book_sessions_amount = 0
					    if service.has_sessions
					      book_sessions_amount = service.sessions_amount
					    end

					    bookings << {
							:service => service.id,
							:provider => provider.id,
							:start => dateTimePointer,
							:end => dateTimePointer + service.duration.minutes,
							:service_name => service.name,
							:provider_name => provider.public_name,
							:provider_lock => serviceStaff[serviceStaffPos][:provider] != "0",
							:provider_id => provider.id,
							:price => service.price,
							:online_payable => service.online_payable,
							:has_discount => service.has_discount,
							:discount => service.discount,
							:show_price => service.show_price,
							:has_time_discount => service.has_time_discount,
							:has_sessions => service.has_sessions,
							:sessions_amount => book_sessions_amount,
							:must_be_paid_online => service.must_be_paid_online
			            }

					    if !service.online_payable || !service.company.company_setting.online_payment_capable
					    	bookings.last[:has_discount] = false
							bookings.last[:has_time_discount] = false
							bookings.last[:discount] = 0
							bookings.last[:time_discount] = 0
					    elsif !service.company.company_setting.promo_offerer_capable
							bookings.last[:has_time_discount] = false
							bookings.last[:time_discount] = 0
					    end

					    if service.has_time_discount && service.online_payable && service.company.company_setting.online_payment_capable && service.company.company_setting.promo_offerer_capable && service.time_promo_active

					      promo = Promo.where(:day_id => now.cwday, :service_promo_id => service.active_service_promo_id, :location_id => local.id).first

					      if !session_booking.nil? && !session_booking.service_promo_id.nil?
					        promo = Promo.where(:day_id => now.cwday, :service_promo_id => session_booking.service_promo_id, :location_id => local.id).first
					      end

					      if !promo.nil?

					        service_promo = ServicePromo.find(service.active_service_promo_id)

					        #Check if there is a limit for bookings, and if there are any left
					        if service_promo.max_bookings > 0 || !service_promo.limit_booking

					          #Check if the promo is still active, and if the booking ends before the limit date

					          if bookings.last[:end].to_datetime < service_promo.book_limit_date && DateTime.now < service_promo.finish_date

					            if !(service_promo.morning_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.morning_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

					              bookings.last[:time_discount] = promo.morning_discount

					            elsif !(service_promo.afternoon_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.afternoon_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

					              bookings.last[:time_discount] = promo.afternoon_discount

					            elsif !(service_promo.night_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.night_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

					              bookings.last[:time_discount] = promo.night_discount

					            else

					              bookings.last[:time_discount] = 0

					            end
					          else
					            bookings.last[:time_discount] = 0
					          end
					        else
					          bookings.last[:time_discount] = 0
					        end

					      else

					        bookings.last[:time_discount] = 0

					      end

					    else

					      bookings.last[:time_discount] = 0

					    end

					    if service.active_service_promo_id.nil?
					      bookings.last[:service_promo_id] = "0"
					    else
					      bookings.last[:service_promo_id] = service.active_service_promo_id
					    end

					    serviceStaffPos += 1

					    if first_service.company.company_setting.allows_optimization
					      if dateTimePointer < provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
					        dateTimePointer = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
					      else
					        dateTimePointer += service.duration.minutes
					      end
					    else
					      dateTimePointer = dateTimePointer + service.duration.minutes
					    end

					    if serviceStaffPos == serviceStaff.count
					      last_check = true

					      #Sum to gap_hours the gap_amount and reset gap flag.
					      if is_gap_hour
					        is_gap_hour = false
					        current_gap = 0
					      end
					    end

					    break

					  end
					end
				end

				logger.debug "***"
				logger.debug "***"
				logger.debug "Reaches before not valid"
				logger.debug "***"
				logger.debug "***"

			  	if !service_valid


				    #Reset gap_hour
				    is_gap_hour = false

				    #First, check if there's a gap. If so, back dateTimePointer to (blocking_start - total_duration)
				    #This way, you can give two options when there are gaps.

				    #Assume there is no gap
				    time_gap = 0

				    if first_service.company.company_setting.allows_optimization && last_check

				      if first_providers.count > 1

				        first_providers.each do |first_provider|

				          book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

				          break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

				          provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

				          if !provider_time_gap.nil?

				            provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

				            if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
				              gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
				              if gap_diff > time_gap
				                time_gap = gap_diff
				              end
				            end

				          end

				          if book_gaps.count > 0
				            gap_diff = (book_gaps.first.start - dateTimePointer)/60
				            if gap_diff != 0
				              if gap_diff > time_gap
				                time_gap = gap_diff
				              end
				            end
				          end

				          if break_gaps.count > 0
				            gap_diff = (break_gaps.first.start - dateTimePointer)/60
				            if gap_diff != 0
				              if gap_diff > time_gap
				                time_gap = gap_diff
				              end
				            end
				          end

				        end

				      else

				        #Get nearest blocking start and check the gap.
				        #Blocking can come from provider time day end.

				        first_provider = first_providers.first

				        book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

				        break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

				        provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

				        if !provider_time_gap.nil?

				          provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

				          if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
				            gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
				            if gap_diff > time_gap
				              time_gap = gap_diff
				            end
				          end

				        end

				        if book_gaps.count > 0
				          gap_diff = (book_gaps.first.start - dateTimePointer)/60
				          if gap_diff != 0
				            if gap_diff > time_gap
				              time_gap = gap_diff
				            end
				          end
				        end

				        if break_gaps.count > 0
				          gap_diff = (break_gaps.first.start - dateTimePointer)/60
				          if gap_diff != 0
				            if gap_diff > time_gap
				              time_gap = gap_diff
				            end
				          end
				        end

				      end

				    end

				    #Check for providers' bookings and breaks that include current dateTimePointer
				    #If any, jump to the nearest end
				    #Else, it's gotta be a resource issue or dtp is outside providers' time, so just add service duration as always
				    #Last part could be optimized to jump to the nearest open provider's time

				    #Time check must be an overlap of (dtp - dtp+service_duration) with booking/break (start - end)

				    smallest_diff = first_service.duration
				    #logger.debug "Defined smallest_diff: " + smallest_diff.to_s


				    #Only do this when there is no gap
				    if first_service.company.company_setting.allows_optimization && time_gap == 0

				      if first_providers.count > 1

				        first_providers.each do |first_provider|


				          book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')

				          if book_blockings.count > 0

				            book_diff = (book_blockings.first.end - dateTimePointer)/60
				            if book_diff < smallest_diff
				              smallest_diff = book_diff

				            end
				          else
				            break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')

				            if break_blockings.count > 0
				              break_diff = (break_blockings.first.end - dateTimePointer)/60
				              if break_diff < smallest_diff
				                smallest_diff = break_diff

				              end
				            end
				          end

				        end

				      else

				        first_provider = first_providers.first

				        book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')

				        if book_blockings.count > 0
				          book_diff = (book_blockings.first.end - dateTimePointer)/60
				          if book_diff < smallest_diff
				            smallest_diff = book_diff
				          end
				        else
				          break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')

				          if break_blockings.count > 0
				            break_diff = (break_blockings.first.end - dateTimePointer)/60
				            if break_diff < smallest_diff
				              smallest_diff = break_diff
				            end
				          end
				        end

				      end

				      if smallest_diff == 0
				        smallest_diff = first_service.duration
				      end

				    else

				      smallest_diff = first_service.company.company_setting.calendar_duration

				    end

				    if first_service.company.company_setting.allows_optimization && time_gap > 0
				      dateTimePointer = (dateTimePointer + time_gap.minutes) - total_services_duration.minutes
				      is_gap_hour = true
				      current_gap = time_gap
				    else
				      current_gap = 0
				      dateTimePointer += smallest_diff.minutes
				    end

				    serviceStaffPos = 0
				    bookings = []

				    last_check = false

				  end
				end

			if bookings.length == serviceStaff.length and (dateTimePointer <=> now + company_setting.after_booking.month) == -1

			  has_time_discount = false
			  bookings_group_discount = 0
			  bookings_group_total_price = 0
			  bookings_group_computed_price = 0

			  bookings.each do |b|
			    bookings_group_total_price = bookings_group_total_price + b[:price]
			    if (b[:has_time_discount] && b[:time_discount] > 0) || (b[:has_discount] && b[:discount] > 0)
			      has_time_discount = true
			      if b[:has_discount] && !b[:has_time_discount]
			        bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
			      elsif !b[:has_discount] && b[:has_time_discount]
			        bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
			      else
			        if b[:discount] > b[:time_discount]
			          bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
			        else
			          bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
			        end
			      end
			    else
			      bookings_group_computed_price = bookings_group_computed_price + b[:price]
			    end
			  end

			  if (bookings_group_total_price != 0)
			    bookings_group_discount = (100 - (bookings_group_computed_price/bookings_group_total_price)*100).round(1)
			  end

			  status = "available"

			  if has_time_discount
			    if session_booking.nil?
			      status = "discount"
			    end
			  end

			  hour_time_diff = ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f

			  if hour_time_diff > max_time_diff
			    max_time_diff = hour_time_diff
			  end

			  curr_promo_discount = 0

			  if bookings.length == 1
			    curr_promo_discount = bookings[0][:time_discount]
			  end

			  if @mandatory_discount

			    if has_time_discount

			    	hour = {
				  		:start => bookings[0][:start].strftime("%H:%M"),
				  		:end => bookings[bookings.length-1][:end].strftime("%H:%M")
					}

			      	new_hour = {
		                index: book_index,
		                date: @date,
		                full_date: I18n.l(bookings[0][:start].to_date, format: :day),
		                hour: hour,
		                bookings: bookings,
		                status: status,
		                start_block: bookings[0][:start].strftime("%H:%M"),
		                end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
		                available_provider: bookings[0][:provider_name],
		                provider: bookings[0][:provider_id],
		                promo_discount: curr_promo_discount.to_s,
		                has_time_discount: bookings[0][:has_time_discount],
		                has_discount: bookings[0][:has_discount],
		                time_discount: bookings[0][:time_discount],
		                discount: bookings[0][:discount],
		                time_diff: hour_time_diff,
		                has_sessions: bookings[0][:has_sessions],
		                sessions_amount: bookings[0][:sessions_amount],
		                group_discount: bookings_group_discount.to_s,
		                service_promo_id: bookings[0][:service_promo_id]
		            }

			      	book_index = book_index + 1
			      	book_summaries << new_hour

			      	if !hours_array.include?(new_hour)

				        hours_array << new_hour
				        total_hours_array << new_hour

				    end

			    end

			  else

			  	hour = {
			  		:start => bookings[0][:start].strftime("%H:%M"),
			  		:end => bookings[bookings.length-1][:end].strftime("%H:%M")
				}

			  	#I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs'

			    new_hour = {
					index: book_index,
					date: @date,
					full_date: I18n.l(bookings[0][:start].to_date, format: :day),
					hour: hour,
					bookings: bookings,
					status: status,
					start_block: bookings[0][:start].strftime("%H:%M"),
					end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
					available_provider: bookings[0][:provider_name],
					provider: bookings[0][:provider_id],
	                promo_discount: curr_promo_discount.to_s,
	                has_time_discount: bookings[0][:has_time_discount],
	                has_discount: bookings[0][:has_discount],
	                time_discount: bookings[0][:time_discount],
		            discount: bookings[0][:discount],
	                time_diff: hour_time_diff,
	                has_sessions: bookings[0][:has_sessions],
	                sessions_amount: bookings[0][:sessions_amount],
	                group_discount: bookings_group_discount.to_s,
	                service_promo_id: bookings[0][:service_promo_id]
	            }

			    book_index = book_index + 1
			    book_summaries << new_hour

			    should_add = true

			    if !session_booking.nil?

			      if !session_booking.service_promo_id.nil? && session_booking.max_discount != 0
			        if new_hour[:group_discount].to_f < session_booking.max_discount.to_f
			          should_add = false
			        end
			      end

			    end

			    #if params[:edit] && status == 'discount'
			      #should_add = false
			    #end

			    if should_add
			      if !hours_array.include?(new_hour)

			        hours_array << new_hour
			        total_hours_array << new_hour

			      end
			    end

			  end

			end

		end

		if serviceStaff[0][:provider] == "0"
	    	@lock = false
	    else
	    	@lock = true
	    end

	    @lock
	    @company = local.company
	    @location = local
	    @serviceStaff = serviceStaff
	    @date = Date.parse(datepicker)
	    @service = Service.find(serviceStaff[0][:service])

	    @available_time = hours_array
	    @bookSummaries = book_summaries

	    logger.debug @available_time.inspect

	    return @available_time

	end

	def check_online_discount
		if !self.online_payable
			self.must_be_paid_online = false
			self.has_time_discount = false
			self.has_discount = false
		#else
			#if self.has_discount
				#self.has_time_discount = false
			#elsif self.has_time_discount
				#self.has_discount = false
			#end
			#self.must_be_paid_online = true
		end
		self.save
	end

	def check_company_promos
		if self.company.company_setting.nil? || self.company.company_setting.promo_time.nil?
			return false
		else
			if !self.company.company_setting.allows_online_payment || !self.company.company_setting.online_payment_capable || !self.company.company_setting.promo_time.active
				return false
			else
				return true
			end
		end
	end

	#Check if all provider times in a day start at the same time
	#True if they start at the same time
	def check_providers_day_times(date)
		day_open = ""
		ProviderTime.where(:service_provider_id => self.service_providers.pluck(:id), :day_id => date.cwday).each do |pt|
			if day_open == ""
				day_open = pt.open
			else
				if day_open != pt.open
					return false
				end
			end
		end
		return true
	end

end
