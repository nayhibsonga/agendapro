class Location < ActiveRecord::Base
	require 'pg_search'
	include PgSearch

	belongs_to :district
	belongs_to :company

	has_many :location_times, dependent: :destroy

	has_many :service_providers, dependent: :destroy
	has_many :active_service_providers, -> { where active: true}, class_name: "ServiceProvider"

	has_many :bookings, dependent: :destroy

	has_many :location_outcall_districts, dependent: :destroy
	has_many :districts, :through => :location_outcall_districts

	has_many :resource_locations, dependent: :destroy
	has_many :resources, :through => :resource_locations

	has_many :user_locations, dependent: :destroy
	has_many :users, :through => :user_locations

	has_many :services, -> { where active: true, online_booking: true }, :through => :active_service_providers

	#has_many :services, -> { where active: true }, :through => :service_providers

	has_many :service_categories, :through => :services

	has_many :economic_sectors, :through => :company

	has_many :economic_sectors_dictionaries, :through => :economic_sectors

	accepts_nested_attributes_for :location_times, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :phone, :company, :district, :presence => true

	validate :times_overlap, :time_empty_or_negative, :provider_time_in_location_time, :plan_locations, :outcall_services
	validate :new_plan_locations, :on => :create

	after_commit :extended_schedule

	pg_search_scope :search_company_name, :associated_against => {
		:company => :name
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
    :ignoring => :accents,
    :ranked_by => ":tsearch + (0.5 * :trigram)"

	pg_search_scope :search, :associated_against => {
		:company => :name,
		:company => :web_address,
		:economic_sectors => :name,
		:economic_sectors_dictionaries => :name,
		:service_categories => :name,
		:services => :name
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
    #:ranked_by => ":tsearch + (0.5 * :trigram)"


	def extended_schedule
		company_setting = self.company.company_setting
		location_ids = self.company.locations.pluck(:id)
		changed = false
		first_open_time = LocationTime.where(location_id: location_ids).order(:open).first.open
		last_close_time = LocationTime.where(location_id: location_ids).order(:close).last.close
		if company_setting.extended_min_hour > first_open_time
			company_setting.extended_min_hour = first_open_time
			changed = true
		end
		if company_setting.extended_max_hour < last_close_time
			company_setting.extended_max_hour = last_close_time
			changed = true
		end
		if changed
			company_setting.save
		end
	end

	def plan_locations
		if self.active_changed? && self.active
			if self.company.locations.where(active:true).count >= self.company.plan.locations
				errors.add(:base, "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
			end
		else
			if self.company.locations.where(active:true).count > self.company.plan.locations
				errors.add(:base, "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
			end
		end
	end

	def new_plan_locations
		if self.company.locations.where(active:true).count >= self.company.plan.locations
			errors.add(:base, "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
		end
	end

	def outcall_services
		if self.outcall
			notOutcall = false
			self.service_providers.each do |service_provider|
				if service_provider.active
					service_provider.services.each do |service|
						if service.active && !service.outcall
							notOutcall = true
						end
					end
				end
			end
			if notOutcall
				errors.add(:base, "El local a domicilio no puede tener prestadores que realizan servicios que no son a domicilio.")
			end
		end
	end

	def times_overlap
    	self.location_times.each do |location_time1|
			self.location_times.each do |location_time2|
				if (location_time1 != location_time2)
					if(location_time1.day_id == location_time2.day_id)
						if (location_time1.open - location_time2.close) * (location_time2.open - location_time1.close) >= 0
				      		errors.add(:base, "Existen bloques horarios sobrepuestos para el día "+location_time1.day.name+".")
				    	end
			    	end
			    end
			end
		end
  	end

  	def time_empty_or_negative
  		self.location_times.each do |location_time|
  			if location_time.open >= location_time.close
  				errors.add(:base, "El horario del día "+location_time.day.name+" es vacío o negativo.")
			end
  		end
  	end

  	def provider_time_in_location_time
  		self.service_providers.each do |service_provider|
			service_provider.provider_times.each do |provider_time|
				provider_time_open = provider_time.open.clone()
				provider_time_close = provider_time.close.clone()
				in_location_time = false
				self.location_times.each do |location_time|
					if provider_time.day_id == location_time.day_id
						if (provider_time_open.change(:month => 1, :day => 1, :year => 2000) >= location_time.open) && (provider_time_close.change(:month => 1, :day => 1, :year => 2000) <= location_time.close)
							in_location_time = true
						end
					end
				end
				if !in_location_time
					errors.add(:base, "El horario del staff "+service_provider.public_name+" no es factible para este local, debes cambiarlo antes de poder cambiar el horario del local.")
				end
			end
		end
	end

	def categorized_services

	    location_resources = self.resource_locations.pluck(:resource_id)
	    service_providers = self.service_providers.where(active: true, online_booking: true)

	    categories = ServiceCategory.where(:company_id => self.company_id).order(order: :asc)
	    services = Service.where(:active => true, online_booking: true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(order: :asc)
	    service_resources_unavailable = ServiceResource.where(service_id: services)
	    if location_resources.any?
	      if location_resources.length > 1
	        service_resources_unavailable = service_resources_unavailable.where('resource_id NOT IN (?)', location_resources)
	      else
	        service_resources_unavailable = service_resources_unavailable.where('resource_id <> ?', location_resources)
	      end
	    end
	    if service_resources_unavailable.any?
	      if service_resources_unavailable.length > 1
	        services = services.where('services.id NOT IN (?)', service_resources_unavailable.pluck(:service_id))
	      else
	        services = services.where('id <> ?', service_resources_unavailable.pluck(:service_id))
	      end
	    end

	    categorized_services = Array.new
	    categories.each do |category|
	      services_array = Array.new
	      services.each do |service|
	        if service.service_category_id == category.id
	          serviceJSON = service.attributes.merge({'name_with_small_outcall' => service.name_with_small_outcall })
	          services_array.push(serviceJSON)
	        end
	      end
	      service_hash = {
	        :id => category.id,
	        :category => category.name,
	        :services => services_array
	      }
	      categorized_services.push(service_hash)
	    end


	    return categorized_services


	    # service_providers = self.service_providers

	    # services_ids = Array.new
	    # services = Array.new
	    # categories = Array.new
	    # service_providers.each do |sp|
	    # 	sp.services.where(active: true).each do |s|
	    # 		services_ids.push(s.id)
	    # 		services.push(s)
	    # 		if(!categories.include?(s.service_category))
	    # 			categories.push(s.service_category)
	    # 		end
	    # 	end
	    # end

	    # return categories

	end

	def categories
		# def location_categorized_services
	 #    location_resources = Location.find(params[:location]).resource_locations.pluck(:resource_id)
	 #    service_providers = ServiceProvider.where(location_id: params[:location])

	 #    categories = ServiceCategory.where(:company_id => Location.find(params[:location]).company_id).order(order: :asc)
	 #    services = Service.where(:active => true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(order: :asc)
	 #    service_resources_unavailable = ServiceResource.where(service_id: services)
	 #    if location_resources.any?
	 #      if location_resources.length > 1
	 #        service_resources_unavailable = service_resources_unavailable.where('resource_id NOT IN (?)', location_resources)
	 #      else
	 #        service_resources_unavailable = service_resources_unavailable.where('resource_id <> ?', location_resources)
	 #      end
	 #    end
	 #    if service_resources_unavailable.any?
	 #      if service_resources_unavailable.length > 1
	 #        services = services.where('services.id NOT IN (?)', service_resources_unavailable.pluck(:service_id))
	 #      else
	 #        services = services.where('id <> ?', service_resources_unavailable.pluck(:service_id))
	 #      end
	 #    end

	 #    categorized_services = Array.new
	 #    categories.each do |category|
	 #      services_array = Array.new
	 #      services.each do |service|
	 #        if service.service_category_id == category.id
	 #          serviceJSON = service.attributes.merge({'name_with_small_outcall' => service.name_with_small_outcall })
	 #          services_array.push(serviceJSON)
	 #        end
	 #      end
	 #      service_hash = {
	 #        :id => category.id,
	 #        :category => category.name,
	 #        :services => services_array
	 #      }
	 #      categorized_services.push(service_hash)
	 #    end

	 #    render :json => categorized_services
	 #  end


	 	# categories = self.service_providers.services.where(:active => true).pluck('service_category_id')
	 	# categories = ServiceCategory.where(:service_id => Service.where(:active => true, :id => ServiceProvider.where(:location_id => loc.id)))
	 	# categories = .service_providers.join(:service).where(:active => true).pluck('service_category_id')

	    service_providers = self.service_providers

	    services_ids = Array.new
	    services = Array.new
	    categories = Array.new
	    service_providers.each do |sp|
	     	sp.services.where(active: true).each do |s|
	     		services_ids.push(s.id)
	     		services.push(s)
	     		if(!categories.include?(s.service_category))
	     			categories.push(s.service_category)
	     		end
	    	end
	    end

	    return categories
	end

	def get_booking_configuration_email
		conf = self.booking_configuration_email
		if conf == 2
			conf = self.company.company_setting.booking_configuration_email
		end
		return conf
	end

	def self.booking_summary
		where(company_id: Company.where(active: true)).where(active: true).where(notification: true).where.not(email: nil).where.not(email: '').each do |location|
			if location.get_booking_configuration_email == 1
				today_schedule = ''
				Booking.where(service_provider_id: ServiceProvider.where(location: location).where(active: true)).where("DATE(start) = DATE(?)", Time.now).where.not(status: Status.find_by(name: 'Cancelado')).order(:start).each do |booking|
					today_schedule += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service_provider.public_name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
										"</tr>"
				end

				booking_summary = ''
				Booking.where(location: location).where(updated_at: (Time.now - 1.day)..Time.now).order(:start).each do |booking|
					booking_summary += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service_provider.public_name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
										"</tr>"
				end
				booking_data = {
					logo: location.company.logo_url,
					name: location.name,
					to: location.email,
					company: location.company.name,
					url: location.company.web_address
				}
				if booking_summary.length > 0 or today_schedule.length > 0
					BookingMailer.booking_summary(booking_data, booking_summary, today_schedule)
				end
			end
		end
	end

	# def categories_alt
	# 	location_resources = self.resource_locations.pluck(:resource_id)
	#     service_providers = self.service_providers.where(active: true)
	#     categories = ServiceCategory.where(:company_id => self.company_id).order(order: :asc)
	#     return categories
	# end

	# def services_alt
	# 	location_resources = self.resource_locations.pluck(:resource_id)
	#     service_providers = self.service_providers.where(active: true)

	#     categories = ServiceCategory.where(:company_id => self.company_id).order(order: :asc)
	#     services = Service.where(:active => true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(order: :asc)
	#     service_resources_unavailable = ServiceResource.where(service_id: services)
	#     if location_resources.any?
	#       if location_resources.length > 1
	#         service_resources_unavailable = service_resources_unavailable.where('resource_id NOT IN (?)', location_resources)
	#       else
	#         service_resources_unavailable = service_resources_unavailable.where('resource_id <> ?', location_resources)
	#       end
	#     end
	#     if service_resources_unavailable.any?
	#       if service_resources_unavailable.length > 1
	#         services = services.where('services.id NOT IN (?)', service_resources_unavailable.pluck(:service_id))
	#       else
	#         services = services.where('id <> ?', service_resources_unavailable.pluck(:service_id))
	#       end
	#     end

	#     return services
	# end

	def get_full_address
		full_address = self.address
		full_address += " " + self.second_address if !self.second_address.blank?
		full_address += ", " + self.district.name
		full_address += ", " + self.district.city.name
		return full_address
	end

	def get_full_address_country
		full_address = self.address
		full_address += " " + self.second_address if !self.second_address.blank?
		full_address += ", " + self.district.name
		full_address += ", " + self.district.city.name
		full_address += ", " + self.district.city.region.name
		full_address += ", " + self.district.city.region.country.name
		return full_address
	end

	def opened_days_zero_index
		opened_days = []
		self.location_times.each do |location_time|
			if !opened_days.include? (location_time.day_id % 7)
				opened_days.push(location_time.day_id % 7)
			end
		end
		return opened_days
	end

	def closed_days_zero_index
		closed_days = [0,1,2,3,4,5,6]
		self.location_times.each do |location_time|
			if closed_days.include? (location_time.day_id % 7)
				closed_days.delete(location_time.day_id % 7)
			end
		end
		return closed_days
	end

end

