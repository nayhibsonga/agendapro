class Location < ActiveRecord::Base

	belongs_to :district
	belongs_to :company

	has_many :location_times
	has_many :service_providers
	has_many :bookings
	has_many :users

	has_many :location_outcall_districts
	has_many :districts, :through => :location_outcall_districts

	  has_many :resource_locations
	  has_many :resources, :through => :resource_locations

	accepts_nested_attributes_for :location_times, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :phone, :company, :district, :presence => true


	validate :times_overlap, :time_empty_or_negative, :provider_time_in_location_time
	validate :plan_locations, :on => :create

	def plan_locations
		@company = self.company
		if company.locations.count >= company.plan.locations
			errors.add(:base, "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
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
					errors.add(:base, "El horario del staff "+service_provider.public_name+" no es posible para este local, debes cambiarlo antes de poder cambiar el horario de este local.")
				end
			end
		end
	end
end
 