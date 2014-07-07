class ServiceProvider < ActiveRecord::Base
	belongs_to :location
	belongs_to :user
	belongs_to :company

	has_many :service_staffs
	has_many :services, :through => :service_staffs
	has_many :provider_times, :inverse_of => :service_provider
	has_many :bookings
	has_many :provider_breaks

	attr_accessor :_destroy

	accepts_nested_attributes_for :user, :reject_if => :all_blank, :allow_destroy => true
	accepts_nested_attributes_for :provider_times, :reject_if => :all_blank, :allow_destroy => true
	
	validates :company, :public_name, :notification_email, :presence => true

	validate :time_empty_or_negative, :time_in_location_time, :times_overlap, :outcall_location_provider, :plan_service_providers

	validate :new_plan_service_providers, :on => :create

	def plan_service_providers
		if self.active_changed? && self.active
			if self.company.service_providers.where(active:true).count >= self.company.plan.service_providers
				errors.add(:base, "No se pueden agregar más proveedores con el plan actual, ¡mejóralo!.")
			end
		else
			if self.company.locations.where(active:true).count > self.company.plan.locations
				errors.add(:base, "No se pueden agregar más proveedores con el plan actual, ¡mejóralo!.")
			end
		end
	end

	def new_plan_service_providers
		if self.company.service_providers.where(active:true).count >= self.company.plan.service_providers
			errors.add(:base, "No se pueden agregar más proveedores con el plan actual, ¡mejóralo!.")
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
				if !service.outcall
					notOutcall = true
				end
			end
			if notOutcall
				errors.add(:base, "Los servicios asociados a un proveedor de una sucursal a domicilio, deben ser exclusivamente servicios a domicilio.")
			end
		end
	end

	def times_overlap
  	self.provider_times.each do |provider_time1|
			self.provider_times.each do |provider_time2|
				if (provider_time1 != provider_time2)
					if(provider_time1.day_id == provider_time2.day_id)
						if (provider_time1.open - provider_time2.close) * (provider_time2.open - provider_time1.close) >= 0
				      		errors.add(:base, "Existen bloques horarios sobrepuestos para el día "+provider_time1.day.name+".")
				    end
			    end
			   end
			end
		end
	end

	def time_empty_or_negative
		self.provider_times.each do |provider_time|
			if provider_time.open >= provider_time.close
				errors.add(:base, "El horario del día "+provider_time.day.name+" es vacío o negativo.")
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
				errors.add(:base, "El horario del día "+provider_time.day.name+" no es posible para ese local.")
			end
		end
	end
end
