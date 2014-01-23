class Location < ActiveRecord::Base

	belongs_to :district
	belongs_to :company

	has_many :location_times
	has_many :service_providers
	has_many :bookings

	accepts_nested_attributes_for :location_times, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :address, :phone, :company, :district, :presence => true


	validate :times_overlap, :time_empty_or_negative, :plan_locations

	def plan_locations
		@company = self.company
		if company.locations.count >= company.plan.locations
			errors.add(:location, "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
		end
	end

	def times_overlap
    	self.location_times.each do |location_time1|
			self.location_times.each do |location_time2|
				if (location_time1 != location_time2)
					if(location_time1.day_id == location_time2.day_id)
						if (location_time1.open - location_time2.close) * (location_time2.open - location_time1.close) >= 0
				      		errors.add(:location, "Existen bloques horarios sobrepuestos.")
				    	end
			    	end
			    end
			end
		end
  	end

  	def time_empty_or_negative
  		self.location_times.each do |location_time|
  			if location_time.open >= location_time.close
  				errors.add(:location, "Existen horarios vacíos o negativos.")
			end
  		end
  	end
end
 