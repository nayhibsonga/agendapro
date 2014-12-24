class Location < ActiveRecord::Base

	belongs_to :district
	belongs_to :company

	has_many :location_times, dependent: :destroy
	has_many :service_providers, dependent: :destroy
	has_many :bookings, dependent: :destroy

	has_many :location_outcall_districts, dependent: :destroy
	has_many :districts, :through => :location_outcall_districts

	has_many :resource_locations, dependent: :destroy
	has_many :resources, :through => :resource_locations

	has_many :user_locations, dependent: :destroy
	has_many :users, :through => :user_locations

	accepts_nested_attributes_for :location_times, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :phone, :company, :district, :presence => true

	validate :times_overlap, :time_empty_or_negative, :provider_time_in_location_time, :plan_locations, :outcall_services
	validate :new_plan_locations, :on => :create

	after_commit :extended_schedule

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
			puts location.name
			if location.get_booking_configuration_email == 1
				Booking.where(location: location).where(updated_at: (Time.now - 1.day)..Time.now).each do |booking|
					puts "%s agendo %s con %s a las %s, %s" % [booking.client.first_name, booking.service.name, booking.service_provider.public_name, booking.start, booking.status.name]
				end
			end
		end
	end

end
 