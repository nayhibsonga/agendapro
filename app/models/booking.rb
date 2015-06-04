class Booking < ActiveRecord::Base
	belongs_to :service_provider
	belongs_to :service
	belongs_to :user
	belongs_to :status
	belongs_to :location
	belongs_to :promotion
	belongs_to :client
	belongs_to :deal
	belongs_to :payed_booking
	belongs_to :session_booking

	has_many :booking_histories, dependent: :destroy

	validates :start, :end, :service_provider_id, :service_id, :status_id, :location_id, :client_id, :presence => true

	validate :time_empty_or_negative, :booking_duration, :service_staff, :client_exclusive, :time_in_provider_time

	validation_scope :warnings do |s|

		s.validate after_commit :time_in_provider_time_warning
		s.validate after_commit :bookings_overlap_warning
		s.validate after_commit :bookings_resources_warning
		s.validate after_commit :bookings_deal_warning
		s.validate after_commit :provider_in_break_warning
	end


	after_commit validate :bookings_overlap, :bookings_resources, :bookings_deal

	after_create :send_booking_mail, :wait_for_payment, :check_session
	after_update :send_update_mail, :check_session

	# def check_session
	# 	if self.is_session
	# 		if self.is_session_booked
	# 			self.sessions_taken = self.sessions_taken + 1
	# 		end
	# 	end
	# end

	def check_session
		if self.id.nil?
			return
		end
		sessions_count = 0
		if !self.session_booking.nil?
			self.session_booking.bookings.each do |b|
				if b.is_session_booked
					sessions_count = sessions_count + 1
				end
			end
			self.session_booking.sessions_taken = sessions_count
			self.session_booking.save
		end
	end

	def wait_for_payment
    	self.delay(run_at: 4.minutes.from_now).payment_timeout
    end

    def payment_timeout
        if !self.payed and self.trx_id != "" and self.payed_booking.nil?
            self.delete
        end
    end

	def time_in_provider_time_warning
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
			if !self.is_session || (self.is_session && self.is_session_booked)
				warnings.add(:base, "El horario o día de la reserva no está disponible para este prestador")
				return
			end
		end
	end

	def provider_in_break_warning
		self.service_provider.provider_breaks.each do |provider_break|
			if self != provider_booking
				if (provider_break.start - self.end) * (self.start - provider_break.end) > 0
					if !self.is_session || (self.is_session && self.is_session_booked) and (!provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked))
						warnings.add(:base, "El prestador seleccionado tiene bloqueado el horario elegido")
		        		return
		        	end
				end
			end
		end
	end

	def bookings_overlap_warning
		cancelled_id = Status.find_by(name: 'Cancelado').id
		unless self.status_id == cancelled_id
			self.service_provider.bookings.each do |provider_booking|
				if provider_booking != self
					unless provider_booking.status_id == cancelled_id
						if (provider_booking.start - self.end) * (self.start - provider_booking.end) > 0
							if !self.service.group_service || self.service_id != provider_booking.service_id
								if (!self.is_session || (self.is_session && self.is_session_booked)) and (!provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked))
									warnings.add(:base, "La hora seleccionada ya está reservada para el prestador elegido")
									return
								end
							elsif self.service.group_service && self.service_id == provider_booking.service_id && self.service_provider.bookings.where(:service_id => self.service_id, :start => self.start).where.not(status_id: Status.find_by_name('Cancelado')).count > self.service.capacity
								if !self.is_session || (self.is_session && self.is_session_booked) and (!provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked))
									warnings.add(:base, "La capacidad del servicio grupal está sobre su límite")
									return
								end
							end
						end
					end
				end
			end
		end
	end

	def bookings_resources_warning
		cancelled_id = Status.find_by(name: 'Cancelado').id
		unless self.status_id == cancelled_id
			if self.service.resources.count > 0
				self.service.resources.each do |resource|
					if !self.location.resource_locations.pluck(:resource_id).include?(resource.id)
						if !self.is_session || (self.is_session && self.is_session_booked)
							warnings.add(:base, "Este local no tiene el(los) recurso(s) necesario(s) para realizar este servicio")
							return
						end
					end
					used_resource = 0
					group_services = []
					self.location.bookings.each do |location_booking|
						if location_booking != self && location_booking.status_id != cancelled_id && (location_booking.start - self.end) * (self.start - location_booking.end) > 0
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
						if !self.is_session || (self.is_session && self.is_session_booked)
							warnings.add(:base, "Este local ya tiene asignado(s) el(los) recurso(s) necesario(s) para realizar este servicio")
							return
						end
					end
				end
			end
		end
	end

	def bookings_deal_warning
		cancelled_id = Status.find_by(name: 'Cancelado').id
		unless self.status_id == cancelled_id
			if !self.deal.nil?
				if !self.is_session || (self.is_session && self.is_session_booked)
					if self.deal.quantity > 0 && self.deal.bookings.where.not(status_id: cancelled_id).count >= self.deal.quantity
						warnings.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida.")
						return
					elsif self.deal.constraint_option > 0 && self.deal.constraint_quantity > 0
						if self.deal.constraint_option == 1
							if self.deal.bookings.where.not(status_id: cancelled_id).where(start: self.start).count >= self.deal.constraint_quantity
								warnings.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida simultáneamente.")
								return
							end
						elsif self.deal.constraint_option == 2
							if self.deal.bookings.where.not(status_id: cancelled_id).where(start: self.start.beginning_of_day..self.start.end_of_day).count >= self.deal.constraint_quantity
								warnings.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida por día.")
								return
							end
						elsif self.deal.constraint_option == 3
							if self.deal.bookings.where.not(status_id: cancelled_id).where(start: self.start.beginning_of_week..self.start.end_of_week).count >= self.deal.constraint_quantity
								warnings.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida por semana.")
								return
							end
						elsif self.deal.constraint_option == 4
							if self.deal.bookings.where.not(status_id: cancelled_id).where(start: self.start.beginning_of_month..self.start.end_of_month).count >= self.deal.constraint_quantity
								warnings.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida por mes.")
								return
							end
						end
					end
				end
			end
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
		unless self.location.company.company_setting.schedule_overcapacity
			if !in_provider_time
				errors.add(:base, "El horario o día de la reserva no está disponible para este prestador")
				return
			end
		else
			if !self.is_session || (self.is_session && self.is_session_booked)
				if self.location.company.company_setting.extended_schedule_bool
					if bstart.change(:month => 1, :day => 1, :year => 2000) < self.location.company.company_setting.extended_min_hour
						errors.add(:base, "La hora de inicio debe ser mayor o igual a la hora mínima que se despliega, puedes extender el horario en las configuraciones del calendario.")
					end
					if bend.change(:month => 1, :day => 1, :year => 2000) > self.location.company.company_setting.extended_max_hour
						errors.add(:base, "La hora de fin debe ser menor o igual a la hora máxima que se despliega, puedes extender el horario en las configuraciones del calendario.")
					end
				else
					location_ids = self.location.company.locations.pluck(:id)
					first_open_time = LocationTime.where(location_id: location_ids).order(:open).first.open
					last_close_time = LocationTime.where(location_id: location_ids).order(:close).last.close
					if bstart.change(:month => 1, :day => 1, :year => 2000) < first_open_time
						errors.add(:base, "La hora de inicio debe ser mayor o igual a la hora de apertura de todas las sucursales, puedes extender el horario en las configuraciones del calendario.")
					end
					if bend.change(:month => 1, :day => 1, :year => 2000) > last_close_time
						errors.add(:base, "La hora de fin debe ser menor o igual a la hora de cierre de todas las sucursales, puedes extender el horario en las configuraciones del calendario.")
					end
				end
			end
		end
	end

	def bookings_overlap
		unless self.location.company.company_setting.provider_overcapacity
			cancelled_id = Status.find_by(name: 'Cancelado').id
			unless self.status_id == cancelled_id
				self.service_provider.bookings.each do |provider_booking|
					if provider_booking != self
						unless provider_booking.status_id == cancelled_id
							if (provider_booking.start - self.end) * (self.start - provider_booking.end) > 0
								if !self.service.group_service || self.service_id != provider_booking.service_id
									if !self.is_session || (self.is_session && self.is_session_booked) and (!provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked))
										errors.add(:base, "La hora seleccionada ya está reservada para el prestador elegido")
										return
									end
								elsif self.service.group_service && self.service_id == provider_booking.service_id && self.service_provider.bookings.where(:service_id => self.service_id, :start => self.start).where.not(status_id: Status.find_by_name('Cancelado')).count > self.service.capacity
									if !self.is_session || (self.is_session && self.is_session_booked) and (!provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked))
										errors.add(:base, "La capacidad del servicio grupal ya llegó a su límite")
										return
									end
								end
							end
						end
					end
				end
			end
		end
	end

	def bookings_resources
		unless self.location.company.company_setting.resource_overcapacity
			cancelled_id = Status.find_by(name: 'Cancelado').id
			unless self.status_id == cancelled_id
				if self.service.resources.count > 0
					self.service.resources.each do |resource|
						if !self.location.resource_locations.pluck(:resource_id).include?(resource.id)
							if !self.is_session || (self.is_session && self.is_session_booked)
								errors.add(:base, "Este local no tiene el(los) recurso(s) necesario(s) para realizar este servicio")
								return
							end
						end
						used_resource = 0
						group_services = []
						self.location.bookings.each do |location_booking|
							if location_booking != self && location_booking.status_id != cancelled_id && (location_booking.start - self.end) * (self.start - location_booking.end) > 0
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
							if !self.is_session || (self.is_session && self.is_session_booked)
								errors.add(:base, "Este local ya tiene asignado(s) el(los) recurso(s) necesario(s) para realizar este servicio")
								return
							end
						end
					end
				end
			end
		end
	end

	def bookings_deal
		if self.location.company.company_setting.deal_activate
			unless self.location.company.company_setting.deal_overcharge
				cancelled_id = Status.find_by(name: 'Cancelado').id
				unless self.status_id == cancelled_id
					if !self.deal.blank?
						if !self.is_session || (self.is_session && self.is_session_booked)
							if self.deal.quantity > 0 && self.deal.bookings.where.not(status_id: cancelled_id).count >= self.deal.quantity
								errors.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida.")
								return
							elsif self.deal.constraint_option > 0 && self.deal.constraint_quantity > 0
								if self.deal.constraint_option == 1
									if self.deal.bookings.where.not(status_id: cancelled_id).where(start: self.start).count >= self.deal.constraint_quantity
										errors.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida simultáneamente.")
										return
									end
								elsif self.deal.constraint_option == 2
									if self.deal.bookings.where.not(status_id: cancelled_id).where(start: self.start.beginning_of_day..self.start.end_of_day).count >= self.deal.constraint_quantity
										errors.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida por día.")
										return
									end
								elsif self.deal.constraint_option == 3
									if self.deal.bookings.where.not(status_id: cancelled_id).where(start: self.start.beginning_of_week..self.start.end_of_week).count >= self.deal.constraint_quantity
										errors.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida por semana.")
										return
									end
								elsif self.deal.constraint_option == 4
									if self.deal.bookings.where.not(status_id: cancelled_id).where(start: self.start.beginning_of_month..self.start.end_of_month).count >= self.deal.constraint_quantity
										errors.add(:base, "Este convenio ya fue utilizado el máximo de veces que era permitida por mes.")
										return
									end
								end
							end
						end
					else
						if self.location.company.company_setting.deal_required
							errors.add(:base, "Es obligatorio incluir un código de convenio para reservar.")
							return
						end
					end
				end
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

	def time_empty_or_negative
		if self.start >= self.end
			errors.add(:base, "La hora de fin es menor o igual a la hora de inicio. Por favor revisa la hora asignada.")
		end
	end

	def client_exclusive
		if self.service_provider.company.company_setting.client_exclusive
			if !self.client.can_book || self.client.identification_number.nil? || self.client.identification_number.empty?
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
		if self.is_session
			return
		end
		if !self.id.nil?
			if self.trx_id == ""
				if self.start > Time.now - eval(ENV["TIME_ZONE_OFFSET"])
					if self.status != Status.find_by(:name => "Cancelado")
						if self.booking_group.nil?
							BookingMailer.book_service_mail(self)
						end
					end
				end
			end
		end
	end

	def send_validate_mail
		if !self.id.nil?
			BookingMailer.book_service_mail(self)
		end
	end

	def send_session_update_mail
		if !self.id.nil?
			if self.start > Time.now - eval(ENV["TIME_ZONE_OFFSET"])
				if !self.is_session_booked
					if changed_attributes['is_session_booked']	
						BookingMailer.cancel_booking(self)
					end
				else
					#if (changed_attributes['start'] || changed_attributes['is_session_booked']) && self.user_session_confirmed
					if changed_attributes['is_session_booked']
						BookingMailer.book_service_mail(self)
					else
						BookingMailer.update_booking(self, changed_attributes['start'])
					end
					#end
				end
			end
		end
	end

	def send_update_mail
		if self.is_session
			return
		end
		if self.start > Time.now - eval(ENV["TIME_ZONE_OFFSET"])
			if self.status == Status.find_by(:name => "Cancelado")
				if changed_attributes['status_id']
					BookingMailer.cancel_booking(self)
				end
				#if !self.payed_booking.nil?
				#	BookingMailer.cancel_payment_mail(self.payed_booking, 1)
				#	BookingMailer.cancel_payment_mail(self.payed_booking, 2)
				#	BookingMailer.cancel_payment_mail(self.payed_booking, 3)
				#end
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
		where(:start => eval(ENV["TIME_ZONE_OFFSET"]).ago...(96.hours - eval(ENV["TIME_ZONE_OFFSET"])).from_now).each do |booking|
			unless booking.status == Status.find_by(:name => "Cancelado")
				booking_confirmation_time = booking.location.company.company_setting.booking_confirmation_time
				if ((booking_confirmation_time.days - eval(ENV["TIME_ZONE_OFFSET"])).from_now..(booking_confirmation_time.days + 1.days - eval(ENV["TIME_ZONE_OFFSET"])).from_now).cover?(booking.start)
					if booking.send_mail
						BookingMailer.book_reminder_mail(booking)
						puts 'Mail enviado a mailer booking_id: ' + booking.id.to_s 
					end
				end
			end
		end
	end

	def generate_ics
		booking = self
		address = ''
		date = I18n.l booking.start
		if !self.service.outcall
			address = booking.location.name + " - " + booking.location.get_full_address
		else
			address = "A domicilio"
		end
		event = RiCal.Calendar do |cal|
		  cal.event do |event|
			event.summary = booking.service.name + ' en ' + booking.location.company.name
			event.description = "Datos de tu reserva:\n- Fecha: " + date + "\n- Servicio: " + booking.service.name + "\n- Prestador: " + booking.service_provider.public_name + "\n- Lugar: " + address + ".\nNOTA: por favor asegúrate que el calendario de tu celular esté en la zona horario correcta. En caso contrario, este recordatorio podría quedar guardado para otra hora."
			event.dtstart =  booking.start.strftime('%Y%m%dT%H%M%S')
			event.dtend = booking.end.strftime('%Y%m%dT%H%M%S')
			event.location = booking.location.get_full_address
			event.add_attendee booking.client.email
			event.alarm do
			  description "Recuerda tu hora de " + booking.service.name + " en "  + booking.location.company.name
			end
		  end
		end
		return event
	end

	def self.generate_csv(type, subtype, year)

		companies = Company.all.order(:name)

		bookings = Hash.new

		companies_info = Hash.new
		for i in 1..12
			companies_info[i] = Array.new
		end

		for i in 1..13
			bookings[i] = Hash.new
			bookings[i]['month'] = ""
			bookings[i]['count'] = 0
			bookings[i]['web'] = 0
		end

		bookings[1]['month'] = "Enero"
		bookings[2]['month'] = "Febrero"
		bookings[3]['month'] = "Marzo"
		bookings[4]['month'] = "Abril"
		bookings[5]['month'] = "Mayo"
		bookings[6]['month'] = "Junio"
		bookings[7]['month'] = "Julio"
		bookings[8]['month'] = "Agosto"
		bookings[9]['month'] = "Septiembre"
		bookings[10]['month'] = "Octubre"
		bookings[11]['month'] = "Noviembre"
		bookings[12]['month'] = "Diciembre"

		cat_bookings = Hash.new
		for i in 1..13
			cat_bookings[i] = Hash.new
			cat_bookings[i]['month'] = ""
			cat_bookings[i]['count'] = 0
			cat_bookings[i]['web'] = 0
		end

		cat_bookings[1]['month'] = "Enero"
		cat_bookings[2]['month'] = "Febrero"
		cat_bookings[3]['month'] = "Marzo"
		cat_bookings[4]['month'] = "Abril"
		cat_bookings[5]['month'] = "Mayo"
		cat_bookings[6]['month'] = "Junio"
		cat_bookings[7]['month'] = "Julio"
		cat_bookings[8]['month'] = "Agosto"
		cat_bookings[9]['month'] = "Septiembre"
		cat_bookings[10]['month'] = "Octubre"
		cat_bookings[11]['month'] = "Noviembre"
		cat_bookings[12]['month'] = "Diciembre"

		# companies.each do |company|
		# 	company_bookings = 0
		# 	company_web_bookings = 0

		# 	for i in 1..12 do

		# 		company_info = Hash.new
		# 		company_info['company'] = company
		# 		company_info['count'] = 0
		# 		company_info['web'] = 0
		# 		month_bookings = 0
		# 		start_date = DateTime.new(year.to_i, i, 1)
		# 		end_date = start_date
		# 		if i < 12	
		# 			end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
		# 		else
		# 			end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
		# 		end

		# 		bookings = Booking.where('start BETWEEN ? and ?', start_date, end_date).where(:location_id => company.locations.pluck(:id))
		# 		bookings_count = bookings.count
				
		# 		web_bookings = bookings.where(:web_origin => true)

		# 		month_bookings = bookings_count
		# 		company_bookings = company_bookings + bookings_count
		# 		company_web_bookings = company_web_bookings + web_bookings.count
		# 		bookings[i]['count'] = @bookings[i]['count'] + bookings_count
		# 		bookings[i]['web'] = @bookings[i]['web'] + web_bookings.count
		# 		bookings[13]['count'] = @bookings[13]['count'] + bookings_count
		# 		bookings[13]['web'] = 	@bookings[13]['web'] + web_bookings.count

		# 		company_info['count'] = month_bookings
		# 		company_info['web'] = web_bookings.count
		# 		companies_info[i] << company_info

		# 	end
		# end


		CSV.generate do |csv|

			header = Array.new
			if type == 'book_date'
				if subtype == 'general'

					header = ["Empresa", "Atributo", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre", "Total"]
					csv << header
					companies.each do |company|

						company_total = 0
						company_web = 0

						row1 = Array.new
						row2 = Array.new
						row3 = Array.new

						row1 << company.name
						row1 << "Total"

						row2 << ""
						row2 << "Web"

						row3 << ""
						row3 << "%"

						for i in 1..12
							month_bookings = 0
							start_date = DateTime.new(year.to_i, i, 1)
							end_date = start_date
							if i < 12	
								end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
							else
								end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
							end

							total_bookings = Booking.where('start BETWEEN ? and ?', start_date, end_date).where(:location_id => company.locations.pluck(:id))
							web_bookings = total_bookings.where(:web_origin => true)

							company_total = company_total + total_bookings.count
							company_web = company_web + web_bookings.count

							row1 << total_bookings.count.to_s
							row2 << web_bookings.count.to_s
							if(total_bookings.count > 0)
								row3 << (web_bookings.count*100/total_bookings.count).to_s
							else
								row3 << "0"
							end
						end

						row1 << company_total.to_s
						row2 << company_web.to_s
						if (company_total > 0)
							row3 << (company_web*100/company_total).to_s
						else
							row3 << "0"
						end
						csv << row1
						csv << row2
						csv << row3
					end

				elsif subtype == 'versus'

					header = ["", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre", "Total"]

					csv << header

					row1 = Array.new
					row2 = Array.new
					row3 = Array.new

					row1 << "Reservas"
					row2 << "Web"
					row3 << "%"

					total = 0
					total_web = 0

					for i in 1..12

						start_date = DateTime.new(year.to_i, i, 1)
						end_date = start_date
						if i < 12	
							end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
						else
							end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
						end

						total_bookings = Booking.where('start BETWEEN ? and ?', start_date, end_date)
						web_bookings = total_bookings.where(:web_origin => true)

						total = total + total_bookings.count
						total_web = total_web + web_bookings.count

						row1 << total_bookings.count.to_s
						row2 << web_bookings.count.to_s
						if total_bookings.count > 0
							row3 << (web_bookings.count * 100 / total_bookings.count).to_s
						else
							row3 << "0"
						end
					end

					row1 << total.to_s
					row2 << total_web.to_s

					if total > 0
						row3 << (total_web*100/total).to_s
					else
						row3 << "0"
					end

					csv << row1
					csv << row2
					csv << row3

				elsif subtype == 'all'

					for i in 1..12

						month_header = Array.new
						month_header << bookings[i]['month']
						csv << month_header
						
						header = Array.new
						header << ""

						row1 = Array.new
						row2 = Array.new
						row3 = Array.new
						row1 << "Reservas"
						row2 << "Web"
						row3 << "%"


						companies_array = Array.new

						books_total = 0
						web_total = 0

						companies.each do |company|

							company_hash = Hash.new
							company_hash['company'] = company
							company_hash['count'] = 0
							company_hash['web'] = 0

							start_date = DateTime.new(year.to_i, i, 1)
							end_date = start_date
							if i < 12	
								end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
							else
								end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
							end

							total_bookings = Booking.where('start BETWEEN ? and ?', start_date, end_date).where(:location_id => company.locations.pluck(:id))

							web_bookings = total_bookings.where(:web_origin => true)

							company_hash['count'] = total_bookings.count
							company_hash['web'] = web_bookings.count

							books_total = books_total + total_bookings.count
							web_total = web_total + web_bookings.count

							companies_array << company_hash

						end

						top_companies = companies_array.sort_by { |info| info['count'] }.reverse
						top_total = 0
						top_web = 0

						for j in 0..9
							header << top_companies[j]['company'].name
							row1 << top_companies[j]['count'].to_s
							row2 << top_companies[j]['web'].to_s
							if top_companies[j]['count'] > 0
								row3 << (top_companies[j]['web']*100/top_companies[j]['count']).to_s
							else
								row3 << "0"
							end
							top_total = top_total + top_companies[j]['count']
							top_web = top_web + top_companies[j]['web']
						end

						row1 << top_total.to_s
						row2 << top_web.to_s 
						if top_total > 0
							row3 << (top_web*100/top_total).to_s
						else
							row3 << "0"
						end

						row1 << books_total.to_s
						row2 << web_total.to_s
						if books_total > 0
							row3 << (web_total*100/books_total).to_s
						else
							row3 << "0"
						end

						header << "Total top"
						header << "Total todos"

						csv << header
						csv << row1
						csv << row2
						csv << row3

					end

				elsif subtype == 'web'

					for i in 1..12

						month_header = Array.new
						month_header << bookings[i]['month']
						csv << month_header
						
						header = Array.new
						header << ""

						row1 = Array.new
						row2 = Array.new
						row3 = Array.new
						row1 << "Reservas"
						row2 << "Web"
						row3 << "%"


						companies_array = Array.new

						books_total = 0
						web_total = 0

						companies.each do |company|

							company_hash = Hash.new
							company_hash['company'] = company
							company_hash['count'] = 0
							company_hash['web'] = 0

							start_date = DateTime.new(year.to_i, i, 1)
							end_date = start_date
							if i < 12	
								end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
							else
								end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
							end

							total_bookings = Booking.where('start BETWEEN ? and ?', start_date, end_date).where(:location_id => company.locations.pluck(:id))

							web_bookings = total_bookings.where(:web_origin => true)

							company_hash['count'] = total_bookings.count
							company_hash['web'] = web_bookings.count

							books_total = books_total + total_bookings.count
							web_total = web_total + web_bookings.count

							companies_array << company_hash

						end

						top_companies = companies_array.sort_by { |info| info['web'] }.reverse
						top_total = 0
						top_web = 0

						for j in 0..9
							header << top_companies[j]['company'].name
							row1 << top_companies[j]['count'].to_s
							row2 << top_companies[j]['web'].to_s
							if top_companies[j]['count'] > 0
								row3 << (top_companies[j]['web']*100/top_companies[j]['count']).to_s
							else
								row3 << "0"
							end
							top_total = top_total + top_companies[j]['count']
							top_web = top_web + top_companies[j]['web']
						end

						row1 << top_total.to_s
						row2 << top_web.to_s 
						if top_total > 0
							row3 << (top_web*100/top_total).to_s
						else
							row3 << "0"
						end

						row1 << books_total.to_s
						row2 << web_total.to_s
						if books_total > 0
							row3 << (web_total*100/books_total).to_s
						else
							row3 << "0"
						end

						header << "Total top"
						header << "Total todos"

						csv << header
						csv << row1
						csv << row2
						csv << row3

					end

				end
			else
				if subtype == 'general'

					header = ["Empresa", "Atributo", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre", "Total"]
					csv << header
					companies.each do |company|

						company_total = 0
						company_web = 0

						row1 = Array.new
						row2 = Array.new
						row3 = Array.new

						row1 << company.name
						row1 << "Total"

						row2 << ""
						row2 << "Web"

						row3 << ""
						row3 << "%"

						for i in 1..12
							month_bookings = 0
							start_date = DateTime.new(year.to_i, i, 1)
							end_date = start_date
							if i < 12	
								end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
							else
								end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
							end

							total_bookings = Booking.where('created_at BETWEEN ? and ?', start_date, end_date).where(:location_id => company.locations.pluck(:id))
							web_bookings = total_bookings.where(:web_origin => true)

							company_total = company_total + total_bookings.count
							company_web = company_web + web_bookings.count

							row1 << total_bookings.count.to_s
							row2 << web_bookings.count.to_s
							if(total_bookings.count > 0)
								row3 << (web_bookings.count*100/total_bookings.count).to_s
							else
								row3 << "0"
							end
						end

						row1 << company_total.to_s
						row2 << company_web.to_s
						if (company_total > 0)
							row3 << (company_web*100/company_total).to_s
						else
							row3 << "0"
						end
						csv << row1
						csv << row2
						csv << row3
					end

				elsif subtype == 'versus'

					header = ["", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre", "Total"]

					csv << header

					row1 = Array.new
					row2 = Array.new
					row3 = Array.new

					row1 << "Reservas"
					row2 << "Web"
					row3 << "%"

					total = 0
					total_web = 0

					for i in 1..12

						start_date = DateTime.new(year.to_i, i, 1)
						end_date = start_date
						if i < 12	
							end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
						else
							end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
						end

						total_bookings = Booking.where('created_at BETWEEN ? and ?', start_date, end_date)
						web_bookings = total_bookings.where(:web_origin => true)

						total = total + total_bookings.count
						total_web = total_web + web_bookings.count

						row1 << total_bookings.count.to_s
						row2 << web_bookings.count.to_s
						if total_bookings.count > 0
							row3 << (web_bookings.count * 100 / total_bookings.count).to_s
						else
							row3 << "0"
						end
					end

					row1 << total.to_s
					row2 << total_web.to_s

					if total > 0
						row3 << (total_web*100/total).to_s
					else
						row3 << "0"
					end

					csv << row1
					csv << row2
					csv << row3

				elsif subtype == 'all'

					

					for i in 1..12

						month_header = Array.new
						month_header << bookings[i]['month']
						csv << month_header
						
						header = Array.new
						header << ""

						row1 = Array.new
						row2 = Array.new
						row3 = Array.new
						row1 << "Reservas"
						row2 << "Web"
						row3 << "%"


						companies_array = Array.new

						books_total = 0
						web_total = 0

						companies.each do |company|

							company_hash = Hash.new
							company_hash['company'] = company
							company_hash['count'] = 0
							company_hash['web'] = 0

							start_date = DateTime.new(year.to_i, i, 1)
							end_date = start_date
							if i < 12	
								end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
							else
								end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
							end

							total_bookings = Booking.where('created_at BETWEEN ? and ?', start_date, end_date).where(:location_id => company.locations.pluck(:id))

							web_bookings = total_bookings.where(:web_origin => true)

							company_hash['count'] = total_bookings.count
							company_hash['web'] = web_bookings.count

							books_total = books_total + total_bookings.count
							web_total = web_total + web_bookings.count

							companies_array << company_hash

						end

						top_companies = companies_array.sort_by { |info| info['count'] }.reverse
						top_total = 0
						top_web = 0

						for j in 0..9
							header << top_companies[j]['company'].name
							row1 << top_companies[j]['count'].to_s
							row2 << top_companies[j]['web'].to_s
							if top_companies[j]['count'] > 0
								row3 << (top_companies[j]['web']*100/top_companies[j]['count']).to_s
							else
								row3 << "0"
							end
							top_total = top_total + top_companies[j]['count']
							top_web = top_web + top_companies[j]['web']
						end

						row1 << top_total.to_s
						row2 << top_web.to_s 
						if top_total > 0
							row3 << (top_web*100/top_total).to_s
						else
							row3 << "0"
						end

						row1 << books_total.to_s
						row2 << web_total.to_s
						if books_total > 0
							row3 << (web_total*100/books_total).to_s
						else
							row3 << "0"
						end

						header << "Total top"
						header << "Total todos"

						csv << header
						csv << row1
						csv << row2
						csv << row3

					end


				elsif subtype == 'web'

					for i in 1..12

						month_header = Array.new
						month_header << bookings[i]['month']
						csv << month_header
						
						header = Array.new
						header << ""

						row1 = Array.new
						row2 = Array.new
						row3 = Array.new
						row1 << "Reservas"
						row2 << "Web"
						row3 << "%"


						companies_array = Array.new

						books_total = 0
						web_total = 0

						companies.each do |company|

							company_hash = Hash.new
							company_hash['company'] = company
							company_hash['count'] = 0
							company_hash['web'] = 0

							start_date = DateTime.new(year.to_i, i, 1)
							end_date = start_date
							if i < 12	
								end_date = DateTime.new(year.to_i, i+1, 1)-1.minutes
							else
								end_date = DateTime.new(year.to_i+1, 1, 1)-1.minutes
							end

							total_bookings = Booking.where('created_at BETWEEN ? and ?', start_date, end_date).where(:location_id => company.locations.pluck(:id))

							web_bookings = total_bookings.where(:web_origin => true)

							company_hash['count'] = total_bookings.count
							company_hash['web'] = web_bookings.count

							books_total = books_total + total_bookings.count
							web_total = web_total + web_bookings.count

							companies_array << company_hash

						end

						top_companies = companies_array.sort_by { |info| info['web'] }.reverse
						top_total = 0
						top_web = 0

						for j in 0..9
							header << top_companies[j]['company'].name
							row1 << top_companies[j]['count'].to_s
							row2 << top_companies[j]['web'].to_s
							if top_companies[j]['count'] > 0
								row3 << (top_companies[j]['web']*100/top_companies[j]['count']).to_s
							else
								row3 << "0"
							end
							top_total = top_total + top_companies[j]['count']
							top_web = top_web + top_companies[j]['web']
						end

						row1 << top_total.to_s
						row2 << top_web.to_s 
						if top_total > 0
							row3 << (top_web*100/top_total).to_s
						else
							row3 << "0"
						end

						row1 << books_total.to_s
						row2 << web_total.to_s
						if books_total > 0
							row3 << (web_total*100/books_total).to_s
						else
							row3 << "0"
						end

						header << "Total top"
						header << "Total todos"

						csv << header
						csv << row1
						csv << row2
						csv << row3

					end

				end
			end
		end

	end

	def self.send_multiple_booking_mail(location, group)
		helper = Rails.application.routes.url_helpers
		@data = {}

		# GENERAL
			bookings = Booking.where(location_id: location).where(booking_group: group).order(:start)
			@data[:company] = bookings[0].location.company.name
			@data[:url] = bookings[0].location.company.web_address
			@data[:signature] = bookings[0].location.company.company_setting.signature
			@data[:logo] = Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
			@data[:type] = 'image/png'
			if bookings[0].location.company.logo_url
				@data[:logo] = Base64.encode64(File.read('public' + bookings[0].location.company.logo_url.to_s))
				@data[:type] = MIME::Types.type_for(bookings[0].location.company.logo_url).first.content_type
			end

		# USER
			@user = {}
			@user[:where] = bookings[0].location.address + ', ' + bookings[0].location.district.name
			@user[:phone] = bookings[0].location.phone
			@user[:name] = bookings[0].client.first_name
			@user[:send_mail] = bookings[bookings.length - 1].send_mail
			@user[:email] = bookings[0].client.email
			@user[:cancel] = helper.cancel_all_booking_url(:confirmation_code => bookings[0].confirmation_code)

			@user_table = ''
			bookings.each do |book|
				@user_table += '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;">' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + book.service.name + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + I18n.l(book.start) + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + book.service_provider.public_name + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + if book.notes.blank? then '' else book.notes end + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' +
							'<a class="btn btn-xs btn-orange" target="_blank" href="' + helper.booking_edit_url(:confirmation_code => book.confirmation_code) + '" style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;text-decoration:none;display:inline-block;margin-bottom:5px;font-weight:normal;text-align:center;white-space:nowrap;vertical-align:middle;-ms-touch-action:manipulation;touch-action:manipulation;cursor:pointer;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;background-image:none;border-width:1px;border-style:solid;padding-top:1px;padding-bottom:1px;padding-right:5px;padding-left:5px;font-size:12px;line-height:1.5;border-radius:3px;color:#ffffff;background-color:#fd9610;border-color:#db7400; width: 90%;">Editar</a>' +
							'<a class="btn btn-xs btn-red" target="_blank" href="' + helper.booking_cancel_url(:confirmation_code => book.confirmation_code) + '" style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;text-decoration:none;display:inline-block;margin-bottom:5px;font-weight:normal;text-align:center;white-space:nowrap;vertical-align:middle;-ms-touch-action:manipulation;touch-action:manipulation;cursor:pointer;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;background-image:none;border-width:1px;border-style:solid;padding-top:1px;padding-bottom:1px;padding-right:5px;padding-left:5px;font-size:12px;line-height:1.5;border-radius:3px;color:#ffffff;background-color:#fd633f;border-color:#e55938; width: 90%;">Cancelar</a>' +
						'</td>' +
					'</tr>'
			end

			@user[:user_table] = @user_table

			@data[:user] = @user

		# LOCATION
			@location = {}
			@location[:name] = bookings[0].location.name
			@location[:client_name] = bookings[0].client.first_name + ' ' + bookings[0].client.last_name
			@location[:send_mail] = bookings[0].location.notification and !bookings[0].location.email.blank? and bookings[0].location.get_booking_configuration_email == 0
			@location[:email] = bookings[0].location.email

			@location_table = ''
			bookings.each do |book|
				@location_table += '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;">' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + book.service.name + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + I18n.l(book.start) + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + if book.notes.blank? then '' else book.notes end + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + if book.company_comment.blank? then '' else book.company_comment end + '</td>' +
					'</tr>'
			end
			@location[:location_table] = @location_table

			@data[:location] = @location

		# SERVICE PROVIDER

			#Get providers ids
			providers_ids = []
			bookings.each do |book|
				if !providers_ids.include?(book.service_provider_id)
					providers_ids << book.service_provider_id
				end
			end

			@provider = {}
			@providers_array = []
			@provider[:client_name] = bookings[0].client.first_name + ' ' + bookings[0].client.last_name

			ServiceProvider.find(providers_ids).each do |provider|
				@staff = {}
				@staff[:name] = provider.public_name
				@staff[:email] = provider.notification_email
				if provider.get_booking_configuration_email == 0
					provider_bookings = Booking.where(location_id: location).where(booking_group: group).where(service_provider: provider).order(:start)
					@provider_table = ''
					provider_bookings.each do |book|
						@provider_table += '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;">' +
								'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + book.service.name + '</td>' +
								'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + I18n.l(book.start) + '</td>' +
								'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + if book.notes.blank? then '' else book.notes end + '</td>' +
								'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + if book.company_comment.blank? then '' else book.company_comment end + '</td>' +
							'</tr>'
					end
					@staff[:provider_table] = @provider_table
					@providers_array << @staff
				end
			end

			@provider[:array] = @providers_array
			@data[:provider] = @provider

		if bookings.order(:start).first.start > Time.now - eval(ENV["TIME_ZONE_OFFSET"])
			BookingMailer.multiple_booking_mail(@data)
		end
	end


end
