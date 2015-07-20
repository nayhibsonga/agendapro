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

	mount_uploader :time_promo_photo, TimePromoPhotoUploader

	scope :with_time_promotions, -> { where(has_time_discount: true, active: true, online_payable: true, online_booking: true, time_promo_active: true) }
	scope :with_last_minute_promotions, -> { where(has_last_minute_discount: true, active: true, online_payable: true, online_booking: true)}

	accepts_nested_attributes_for :service_category, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :duration, :company, :service_category, :presence => true
	validates :duration, numericality: { greater_than_or_equal_to: 5, :less_than_or_equal_to => 1439 }
	validates :price, numericality: { greater_than_or_equal_to: 0 }

	validate :group_service_capacity, :outcall_providers

	pg_search_scope :search, 
	:against => :name,
	:associated_against => {
		:service_category => :name
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

    #def active_service_promo
    #	if self.active_service_promo_id.nil?
    #		return nil
    #	else
    #		return ServicePromo.find(self.active_service_promo_id)
    #	end
    #end

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
			service_promo.max_bookings
		end
	end

	def active_promo_left_bookings

		if self.active_service_promo_id.nil?

			return 0

		else

			service_promo = ServicePromo.find(self.active_service_promo_id)
			bookings_count = Booking.where(:service_promo_id => service_promo.id, :is_session => false).where('status_id <> ?', Status.find_by_name('Cancelado')).count
			session_bookings_count = SessionBooking.where(:service_promo_id => service_promo.id).count

			if service_promo.max_bookings.nil?
				service_promo.max_bookings = 0
				service_promo.save
				return 0
			end

			return service_promo.max_bookings - (bookings_count + session_bookings_count)

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

	def get_last_minute_available_hours(provider_id, location_id)

		available_hours = []

		location = Location.find(location_id)

		last_minute_hours = self.get_last_minute_hours(location_id)

		now = DateTime.now
		now_m = now.min

		if self.duration < 60
			if now_m < self.duration
				now = now + (self.duration - now_m).minutes + self.duration.minutes
			else
				now = now + 1.hours
				now = now - now_m.minutes
				now = now + self.duration.minutes
			end
		else
			now = now + 2.hours
			now = now - now_m.minutes
		end

		day = now.cwday

		open_time = location.location_times.where(day_id: day).order(:open).first.open
		close_time = location.location_times.where(day_id: day).order(:close).first.close

		dateTimePointer = DateTime.new(now.year, now.mon, now.mday, now.hour, now.min)
		open = DateTime.new(now.year, now.mon, now.mday, open_time.hour, open_time.min)
		close = DateTime.new(now.year, now.mon, now.mday, close_time.hour, close_time.min)

		

		limit = DateTime.now + last_minute_hours.hours
		limit = DateTime.new(limit.year, limit.mon, limit.mday, limit.hour, limit.min)

		puts "Times: "
		puts "DTP: " + dateTimePointer.to_s
		puts "Open: " + open.to_s
		puts "Close: " + close.to_s
		puts "Limit: " + limit.to_s	

		if dateTimePointer > close
			return available_hours
		end

		if DateTime.now < (open - last_minute_hours.hours)
			return available_hours
		end

		puts provider_id.to_s

		if provider_id.nil? || provider_id == "0" || provider_id == 0
			
			puts "Sin preferencia"

			while dateTimePointer < limit && dateTimePointer < close
				
				service_valid = false

				#Check dtp + duration isn't out of location time
				if (dateTimePointer + self.duration.minutes) > close
					service_valid = false
					break
				else
					service_valid = true
				end

				self.service_providers.each do |service_provider|

					provider_time = service_provider.provider_times.where(day_id: day).first

					provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
	              	provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

	              	#Check provider times
	              	if provider_open > dateTimePointer || provider_close < (dateTimePointer + self.duration.minutes)
	              		service_valid = false
	              		break
	              	else
	              		service_valid = true
	              	end

	              	#Check provider breaks
		            if service_valid
		              	service_provider.provider_breaks.each do |provider_break|
		                	if !(provider_break.end.to_datetime <= dateTimePointer || (dateTimePointer + self.duration.minutes) <= provider_break.start.to_datetime)
		                  		service_valid = false
		                  		break
		                	end
		              	end
		            end

		            # Cross Booking
		            if service_valid
		              Booking.where(service_provider_id: service_provider.id, start: dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |provider_booking|
		                unless provider_booking.status_id == cancelled_id
		                  pointerEnd = dateTimePointer + self.duration.minutes
		                  if (pointerEnd <= provider_booking.start.to_datetime || provider_booking.end.to_datetime <= dateTimePointer)
		                    if !self.group_service || self.id != provider_booking.service_id
		                      if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
		                        service_valid = false
		                        break
		                      end
		                    elsif self.group_service && self.id == provider_booking.service_id && provider.bookings.where(service_id: self.id, start: dateTimePointer).where.not(status_id: Status.find_by_name('Cancelado')).count >= self.capacity
		                      if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
		                        service_valid = false
		                        break
		                      end
		                    end
		                  else
		                    if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
		                      service_valid = false
		                    end
		                  end
		                end
		              end
		            end


		            # Recursos
		            if service_valid and self.resources.count > 0
		              self.resources.each do |resource|
		                if !location.resource_locations.pluck(:resource_id).include?(resource.id)
		                  service_valid = false
		                  break
		                end
		                used_resource = 0
		                group_services = []
		                location.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
		                  if location_booking.status_id != cancelled_id && (location_booking.end.to_datetime <= dateTimePointer || (dateTimePointer + self.duration.minutes) <= location_booking.start.to_datetime)
		                    if location_booking.service.resources.include?(resource)
		                      if !location_booking.service.group_service
		                        used_resource += 1
		                      else
		                        if location_booking.service != self || location_booking.service_provider != provider
		                          group_services.push(location_booking.service_provider.id)
		                        end
		                      end
		                    end
		                  end
		                end
		                if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: location.id).first.quantity
		                  service_valid = false
		                  break
		                end
		              end
		            end

		            if service_valid

		              available_hours << {
		                :service => self.id,
		                :provider => service_provider.id,
		                :start => dateTimePointer,
		                :end => dateTimePointer + self.duration.minutes,
		                :service_name => self.name,
		                :provider_name => service_provider.public_name,
		                :provider_lock => true
		              }
		              dateTimePointer += self.duration.minutes
		              break #Break providers loop
		            end

		            dateTimePointer += self.duration.minutes

		        end

			end


		else

			service_provider = ServiceProvider.find(provider_id)

			puts service_provider.public_name

			while dateTimePointer < limit && dateTimePointer < close
				
				service_valid = false

				#Check dtp + duration isn't out of location time
				if (dateTimePointer + self.duration.minutes) > close
					service_valid = false
					puts "Break 1"
					puts (dateTimePointer + self.duration.minutes).to_s
					puts close.to_s
					break
				else
					service_valid = true
				end

				puts "Service valid 1"

				provider_time = service_provider.provider_times.where(day_id: day).first

				provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
              	provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

              	#Check provider times
              	if provider_open > dateTimePointer || provider_close < (dateTimePointer + self.duration.minutes)
              		service_valid = false
              		break
              	else
              		service_valid = true
              	end

              	puts "Service valid 2"

              	#Check provider breaks
	            if service_valid
	              	service_provider.provider_breaks.each do |provider_break|
	                	if !(provider_break.end.to_datetime <= dateTimePointer || (dateTimePointer + self.duration.minutes) <= provider_break.start.to_datetime)
	                  		service_valid = false
	                  		break
	                	end
	              	end
	            end

              	puts "Service valid 3"


	            # Cross Booking
	            if service_valid
	              Booking.where(service_provider_id: service_provider.id, start: dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |provider_booking|
	                unless provider_booking.status_id == cancelled_id
	                  pointerEnd = dateTimePointer + self.duration.minutes
	                  if (pointerEnd <= provider_booking.start.to_datetime || provider_booking.end.to_datetime <= dateTimePointer)
	                    if !self.group_service || self.id != provider_booking.service_id
	                      if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
	                        service_valid = false
	                        break
	                      end
	                    elsif self.group_service && self.id == provider_booking.service_id && provider.bookings.where(service_id: self.id, start: dateTimePointer).where.not(status_id: Status.find_by_name('Cancelado')).count >= self.capacity
	                      if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
	                        service_valid = false
	                        break
	                      end
	                    end
	                  else
	                    if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
	                      service_valid = false
	                    end
	                  end
	                end
	              end
	            end

	            puts "Service valid 4"


	            # Recursos
	            if service_valid and self.resources.count > 0
	              self.resources.each do |resource|
	                if !location.resource_locations.pluck(:resource_id).include?(resource.id)
	                  service_valid = false
	                  break
	                end
	                used_resource = 0
	                group_services = []
	                location.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
	                  if location_booking.status_id != cancelled_id && (location_booking.end.to_datetime <= dateTimePointer || (dateTimePointer + self.duration.minutes) <= location_booking.start.to_datetime)
	                    if location_booking.service.resources.include?(resource)
	                      if !location_booking.service.group_service
	                        used_resource += 1
	                      else
	                        if location_booking.service != self || location_booking.service_provider != provider
	                          group_services.push(location_booking.service_provider.id)
	                        end
	                      end
	                    end
	                  end
	                end
	                if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: location.id).first.quantity
	                  service_valid = false
	                  break
	                end
	              end
	            end

	            puts "Service valid 5"

	            if service_valid

	              available_hours << {
	                :service => self.id,
	                :provider => service_provider.id,
	                :start => dateTimePointer,
	                :end => dateTimePointer + self.duration.minutes,
	                :service_name => self.name,
	                :provider_name => service_provider.public_name,
	                :provider_lock => true
	              }
	            end

	            dateTimePointer += self.duration.minutes

			end

		end

		return available_hours

	end

	def check_online_discount
		if !self.online_payable
			self.must_be_paid_online = false
			self.has_time_discount = false
			self.has_discount = false
		else
			if self.has_discount
				self.has_time_discount = false
			elsif self.has_time_discount
				self.has_discount = false
			end
			self.must_be_paid_online = true
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

end
