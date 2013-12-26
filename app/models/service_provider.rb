class ServiceProvider < ActiveRecord::Base
	belongs_to :location
	belongs_to :user
	belongs_to :company

	has_many :services, :through => :services_staffs
	has_many :provider_times
	has_many :bookings

	accepts_nested_attributes_for :provider_times, :reject_if => :all_blank, :allow_destroy => true
	
	validates :company, :user, :location, :presence => true

	def times_overlap
    	self.provider_times.each do |provider_time1|
			self.provider_times.each do |provider_time2|
				if (provider_time1 != provider_time2)
					if(provider_time1.day_id == provider_time2.day_id)
						if (provider_time1.open - provider_time2.close) * (provider_time2.open - provider_time1.close) >= 0
				      		errors.add(:service_provider, "Existen bloques horarios sobrepuestos.")
				    	end
			    	end
			    end
			end
		end
  	end

  	def time_empty_or_negative
  		self.provider_times.each do |provider_time|
  			if provider_time.open >= provider_time.close
  				errors.add(:service_provider, "Existen horarios vacíos o negativos.")
			end
  		end
  	end
end
