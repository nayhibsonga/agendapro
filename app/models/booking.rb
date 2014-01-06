class Booking < ActiveRecord::Base
	belongs_to :service_provider
	belongs_to :service
	belongs_to :user
	belongs_to :status
	belongs_to :location
	belongs_to :promotion

	validates :start, :end, :service_provider_id, :service_id, :status_id, :location_id, :first_name, :last_name, :mail, :phone, :presence => true

	validate :time_empty_or_negative, :time_in_provider_time, :booking_duration, :service_staff

	after_commit validate :bookings_overlap

	def booking_duration
    	if self.service.duration != ((self.end - self.start) / 1.minute ).round
    		errors.add(:service_provider, "La duración de la reserva no coincide con la duración del servicio.")
    	end
  	end

  	def service_staff
    	if !self.service_provider.services.include?(self.service)
    		errors.add(:service_provider, "El proveedor de servicios no puede realizar este servicio.")
    	end
  	end

  	def bookings_overlap
		self.service_provider.bookings.each do |provider_booking|
			if (provider_booking.start - self.end) * (self.start - provider_booking.end) > 0
	      		errors.add(:service_provider, "Esa hora ya está agendada para ese proveedor de servicios.")
	    	end
		end
  	end

  	def time_empty_or_negative
		if self.start >= self.end
			errors.add(:service_provider, "Existen horarios vacíos o negativos.")
  		end
  	end

  	def time_in_provider_time
		bstart = self.start.clone()
		bend = self.end.clone()
		bstart_wday = bstart.wday
		bend_wday = bend.wday
		if bstart_wday == 0 then bstart_wday = 7 end
		#if bend_wday == 0 then bend_wday = 7 end
		in_provider_time = false
		self.service_provider.provider_times.each do |provider_time|
			if bstart_wday == provider_time.day_id
				if (bstart.change(:month => 1, :day => 1, :year => 2000) >= provider_time.open) && (bend.change(:month => 1, :day => 1, :year => 2000) <= provider_time.close)
					in_provider_time = true
				end
			end
		end
		if !in_provider_time
			errors.add(:service_provider, "El horario de la reserva no es posible para ese proveedor de servicio.")
		end
  	end
end
