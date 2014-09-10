class Booking < ActiveRecord::Base
	belongs_to :service_provider
	belongs_to :service
	belongs_to :user
	belongs_to :status
	belongs_to :location
	belongs_to :promotion
	belongs_to :client

	validates :start, :end, :service_provider_id, :service_id, :status_id, :location_id, :client_id, :presence => true

	validate :time_empty_or_negative, :booking_duration, :service_staff, :time_in_provider_time, :client_exclusive

	after_commit validate :bookings_overlap

	after_create :send_booking_mail
	after_update :send_update_mail

	def provider_in_break
		self.service_provider.provider_breaks.each do |provider_break|
			if (provider_break.start - self.end) * (self.start - provider_break.end) > 0
				errors.add(:base, "El prestador seleccionado tiene bloqueado el horario elegido. Por favor elige otro horario o selecciona otro prestador.")
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
			errors.add(:base, "El prestador seleccionado no realiza el servicio elegido en la reserva. Por favor agrega el servicio al prestador o elige otro prestador.")
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
								errors.add(:base, "La hora seleccionada ya está reservada para el prestador elegido. Por favor selecciona otra hora disponible.")
								return
							elsif self.service.group_service && self.service_id == provider_booking.service_id && self.service_provider.bookings.where(:service_id => self.service_id, :start => self.start).count >= self.service.capacity
								errors.add(:base, "La capacidad del servicio grupal ya llegó a su límite. Por favor selecciona otra hora disponible.")
								return
							end
						end
					end	
				end
			end
			if self.service.resources.count > 0
				self.service.resources.each do |resource|
					if !self.location.resource_locations.pluck(:resource_id).include?(resource.id)
						errors.add(:base, "Este local no tiene el(los) recurso(s) necesario(s) para realizar este servicio.")
						return
					end
					used_resource = 0
					group_services = []
					self.location.bookings.each do |location_booking|
						if location_booking != self && location_booking != cancelled_id && (location_booking.start - self.end) * (self.start - location_booking.end) > 0
							if location_booking.service.resources.include?(resource)
								if !location_booking.service.group_service
									used_resource += 1
								else
									if location_booking.service != self.service || location_booking.service_provider != self.service_provider
										group_services.push(location_booking.service_provider.id)
									end
								end		
							end
						end
					end
					if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: self.location.id).first.quantity
						errors.add(:base, "Este local ya tiene asignado(s) el(los) recurso(s) necesario(s) para realizar este servicio.")
						return
					end
				end
			end
		end
	end

	def time_empty_or_negative
		if self.start >= self.end
			errors.add(:base, "La hora de fin es menor a la hora de inicio. Por favor revisa la hora asignada.")
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
			errors.add(:base, "El horario o día de la reserva no está disponible para este prestador.")
		end
	end

	def client_exclusive
		if self.service_provider.company.company_setting.client_exclusive
			if !self.client.can_book
				errors.add(:base, "El cliente ingresado no figura en los registros o no puede reservar.")
			end
		end
	end

	def confirmation_code
		crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
		encrypted_data = crypt.encrypt_and_sign(self.id.to_s)
		return encrypted_data
	end

	def send_booking_mail
		if self.start > Time.now - 4.hours
			if self.status != Status.find_by(:name => "Cancelado")
				BookingMailer.book_service_mail(self)
			end
		end
	end

	def send_update_mail
		if self.start > Time.now - 4.hours
			if self.status == Status.find_by(:name => "Cancelado")
				BookingMailer.cancel_booking(self)
			else
				if changed_attributes['start']
					BookingMailer.update_booking(self, changed_attributes['start'])
				elsif changed_attributes['status_id'] and self.status == Status.find_by(:name => "Confirmado")
					BookingMailer.confirm_booking(self)
				end
			end
		end
	end

	def self.booking_reminder
		where(:start => 20.hours.from_now...44.hours.from_now).each do |booking|
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
			event.description = "Se reservó " + booking.service.name + " en "  + booking.location.name + ", con una duración de " + booking.service.duration.to_s
			event.dtstart =  DateTime.parse(booking.start.to_s).new_offset('+04:00')
			event.dtend = DateTime.parse(booking.end.to_s).new_offset('+04:00')
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
