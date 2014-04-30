class Booking < ActiveRecord::Base
	belongs_to :service_provider
	belongs_to :service
	belongs_to :user
	belongs_to :status
	belongs_to :location
	belongs_to :promotion

	validates :start, :end, :service_provider_id, :service_id, :status_id, :location_id, :first_name, :last_name, :email, :presence => true

	validate :time_empty_or_negative, :time_in_provider_time, :booking_duration, :service_staff

	after_commit validate :bookings_overlap, :provider_in_break

	after_create :send_booking_mail, :check_company_client
	after_update :send_update_mail

	def provider_in_break
		self.service_provider.provider_breaks.each do |provider_break|
	    	if (provider_break.start - self.end) * (self.start - provider_break.end) > 0
	    		errors.add(:base, "El proveedor seleccionado ha bloqueado ese horario.")
	    	end
    	end
  	end

	def booking_duration
    	if self.service.duration != ((self.end - self.start) / 1.minute ).round
    		errors.add(:base, "La duración de la reserva no coincide con la duración del servicio.")
    	end
  	end

  	def service_staff
    	if !self.service_provider.services.include?(self.service)
    		errors.add(:base, "El proveedor de servicios no puede realizar este servicio.")
    	end
  	end

  	def bookings_overlap
		self.service_provider.bookings.each do |provider_booking|
			if provider_booking != self
	  			unless provider_booking.status_id == Status.find_by(name: 'Cancelado').id
					if (provider_booking.start - self.end) * (self.start - provider_booking.end) > 0
						if !self.service.group_service || self.service_id != provider_booking.service_id
			      			errors.add(:base, "Esa hora ya está agendada para ese proveedor de servicios.")
			      		elsif self.service.group_service && self.service_id == provider_booking.service_id && self.service_provider.bookings.where(:service_id => self.service_id, :start => self.start).count >= self.service.capacity
			      			errors.add(:base, "Esa hora ya está agendada para ese proveedor de servicios.")
			      		end
			    	end
				end	
			end
  		end
  	end

  	def time_empty_or_negative
		if self.start >= self.end
			errors.add(:base, "Existen horarios vacíos o negativos.")
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
			errors.add(:base, "El horario o día de la reserva no es posible para ese proveedor de servicio.")
		end
  	end

  	def confirmation_code
  		id = self.id.to_s
  		id_length = id.length.to_s
  		local_id = self.location_id.to_s
  		service_id = self.service_id.to_s
  		provider_id = self.service_provider_id.to_s
  		return id + local_id + service_id + provider_id + '-' + id_length
  	end

  	def send_booking_mail
		BookingMailer.book_service_mail(self)
	end

	def send_update_mail
		if self.status == Status.find_by(:name => "Cancelado")
			BookingMailer.cancel_booking(self)
		else
			if changed_attributes[:start]
				BookingMailer.update_booking(self)
			end
		end
	end

	def self.booking_reminder
		@time1 = Time.new.getutc + 1.day
		@time2 = Time.new.getutc + 2.day
		where(:start => @time1...@time2).each do |booking|
			unless booking.status == Status.find_by(:name => "Cancelado")
				booking.update_column(:status_id, Status.find_by(:name => "Confirmado")) unless booking.status == Status.find_by(:name => "Pagado")
				BookingMailer.book_reminder_mail(booking)
			end
		end
	end

	def check_company_client
		if Client.where(:company_id => self.location.company.id, :email => self.email).empty?
        	Client.create(:company_id => self.location.company.id, :email => self.email, :first_name => self.first_name, :last_name => self.last_name, :phone => self.phone)
        end
    end
end
