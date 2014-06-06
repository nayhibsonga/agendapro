class Booking < ActiveRecord::Base
	belongs_to :service_provider
	belongs_to :service
	belongs_to :user
	belongs_to :status
	belongs_to :location
	belongs_to :promotion
	belongs_to :client

	validates :start, :end, :service_provider_id, :service_id, :status_id, :location_id, :presence => true

	validate :time_empty_or_negative, :booking_duration, :service_staff, :time_in_provider_time

	after_commit validate :bookings_overlap

	after_create :send_booking_mail
	after_update :send_update_mail

	def provider_in_break
		self.service_provider.provider_breaks.each do |provider_break|
			if (provider_break.start - self.end) * (self.start - provider_break.end) > 0
				errors.add(:base, "El proveedor seleccionado ha bloqueado ese horario.")
			end
		end
	end

	def booking_duration
		if ((self.end - self.start) / 1.minute ).round < 5
			errors.add(:base, "La duración de la reserva no puede ser menor a 5 minutos.")
		end
	end

	def service_staff
		if !self.service_provider.services.include?(self.service)
			errors.add(:base, "El proveedor de servicios no puede realizar este servicio.")
		end
	end

	def bookings_overlap
		cancelled_id = Status.find_by(name: 'Cancelado').id
		unless self.status_id == cancelled_id
			self.service_provider.bookings.each do |provider_booking|
				if provider_booking != self
					unless provider_booking.status_id == cancelled_id
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
		crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
		encrypted_data = crypt.encrypt_and_sign(self.id.to_s)
		return encrypted_data
	end

	def send_booking_mail
		if self.send_mail
			BookingMailer.book_service_mail(self)
		end
	end

	def send_update_mail
		if self.status == Status.find_by(:name => "Cancelado")
			if self.send_mail
				BookingMailer.cancel_booking(self)
			end
		else
			if changed_attributes['start'] and self.send_mail
				BookingMailer.update_booking(self)
			end
			if self.status == Status.find_by(:name => "Confirmado")
				BookingMailer.confirm_booking(self)
			end
		end
	end

	def self.booking_reminder
		@time1 = Time.new.getutc + 1.day
		@time2 = Time.new.getutc + 2.day
		where(:start => @time1...@time2).each do |booking|
			unless booking.status == Status.find_by(:name => "Cancelado") 
				if booking.send_mail
					BookingMailer.book_reminder_mail(booking)
				end
			end
		end
	end

	def generate_ics
		booking = self
		event = RiCal.Calendar do |cal|
		  cal.event do |event|
			event.summary = booking.service.name + ' en ' + booking.location.name
			event.description = "Se reservo " + booking.service.name + " en "  + booking.location.name + ", con una duracion de " + booking.service.duration.to_s
			event.dtstart =  DateTime.parse(booking.start.to_s)
			event.dtend = DateTime.parse(booking.end.to_s)
			event.location = booking.location.address
			event.add_attendee booking.client.email
			event.alarm do
			  description "Recuerda " + booking.service.name + " en "  + booking.location.name
			end
		  end
		end
		return event
	end
end
