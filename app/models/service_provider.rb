class ServiceProvider < ActiveRecord::Base
	belongs_to :location
	belongs_to :user
	belongs_to :company

	has_many :service_staffs
	has_many :services, :through => :service_staffs
	has_many :provider_times, :inverse_of => :service_provider
	has_many :bookings

	attr_accessor :_destroy

	accepts_nested_attributes_for :user, :reject_if => :all_blank, :allow_destroy => true
	accepts_nested_attributes_for :provider_times, :reject_if => :all_blank, :allow_destroy => true
	
	validates :company, :user, :location, :presence => true

	validate :time_empty_or_negative, :time_in_location_time, :times_overlap
	validate :plan_service_providers, :on => :create

	def plan_service_providers
		@company = self.company
		if company.service_providers.count >= company.plan.service_providers
			errors.add(:service_provider, "No se pueden agregar más proveedores de servicios con el plan actual, ¡mejóralo!.")
		end
	end

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
				errors.add(:service_provider, "El horario del staff no es posible para ese local.")
			end
		end
	end
end
