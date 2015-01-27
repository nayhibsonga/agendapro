class ServiceProvider < ActiveRecord::Base
	belongs_to :location
	belongs_to :company

	has_many :service_staffs, dependent: :destroy
	has_many :services, :through => :service_staffs

	has_many :user_providers, dependent: :destroy
	has_many :users, :through => :user_providers

	has_many :provider_times, :inverse_of => :service_provider, dependent: :destroy
	has_many :bookings, dependent: :destroy
	has_many :provider_breaks, dependent: :destroy

	attr_accessor :_destroy

	accepts_nested_attributes_for :provider_times, :reject_if => :all_blank, :allow_destroy => true

	validates :company, :public_name, :notification_email, :location, :presence => true

	validate :time_empty_or_negative, :time_in_location_time, :times_overlap, :outcall_location_provider, :plan_service_providers

	validate :new_plan_service_providers, :on => :create

	def plan_service_providers
		if self.active_changed? && self.active
			if self.company.service_providers.where(active:true).count >= self.company.plan.service_providers
				errors.add(:base, "No se pueden agregar más prestadores con el plan actual, ¡mejóralo!.")
			end
		else
			if self.company.locations.where(active:true).count > self.company.plan.locations
				errors.add(:base, "No se pueden agregar más prestadores con el plan actual, ¡mejóralo!.")
			end
		end
	end

	def new_plan_service_providers
		if self.company.service_providers.where(active:true).count >= self.company.plan.service_providers
			errors.add(:base, "No se pueden agregar más prestadores con el plan actual, ¡mejóralo!.")
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
				if service.active
					if !service.outcall
						notOutcall = true
					end
				end
			end
			if notOutcall
				errors.add(:base, "Los servicios asociados a un prestador de una sucursal a domicilio, deben ser exclusivamente servicios a domicilio.")
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
				errors.add(:base, "El horario del día "+provider_time.day.name+" no es factible para el local seleccionado.")
			end
		end
	end

	def provider_booking_day_occupation(date)
		available_time = 0.0
		used_time = 0.0
		self.provider_times.each do |provider_time|
			available_time += provider_time.close - provider_time.open
		end
		Booking.where(service_provider_id: self.id, start: date.to_time.beginning_of_day..date.to_time.end_of_day).each do |booking|
			used_time += booking.end - booking.start
		end
		occupation = used_time/available_time
		if occupation > 0
			return occupation
		else
			return 0
		end
	end

	def get_booking_configuration_email
		conf = self.booking_configuration_email
		if conf == 2
			conf = self.location.get_booking_configuration_email
		end
		return conf
	end

	def self.booking_summary
		where(company_id: Company.where(active: true)).where(location_id: Location.where(active: true)).where(active: true).each do |provider|
			if provider.get_booking_configuration_email == 1
				today_schedule = ''
				Booking.where(service_provider: provider).where("DATE(start) = DATE(?)", Time.now).where.not(status: Status.find_by(name: 'Cancelado')).order(:start).each do |booking|
					today_schedule += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.duration.to_s + " minutos</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
										"</tr>"
				end

				booking_summary = ''
				Booking.where(service_provider: provider).where(updated_at: (Time.now - 1.day)..Time.now).order(:start).each do |booking|
					booking_summary += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.duration.to_s + " minutos</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
											"<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
										"</tr>"
				end
				booking_data = {
					logo: provider.location.company.logo_url,
					name: provider.public_name,
					to: provider.notification_email,
					company: provider.location.company.name,
					url: provider.location.company.url
				}
				if booking_summary.length > 0 or today_schedule.length > 0
					BookingMailer.booking_summary(booking_data, booking_summary, today_schedule)
				end
			end
		end
	end
end
