class SessionBooking < ActiveRecord::Base
	has_many :bookings
	has_many :booked_bookings, -> { where is_session_booked: true, user_session_confirmed: true}, class_name: "Booking"
	has_many :unbooked_bookings, -> { where is_session_booked: false}, class_name: "Booking"
	has_many :unvalidated_bookings, -> { where is_session_booked: true, user_session_confirmed: false}, class_name: "Booking"
	belongs_to :service
	belongs_to :user
	belongs_to :client


	def send_sessions_booking_mail
		helper = Rails.application.routes.url_helpers
		@data = {}

		location = self.bookings.first.location.id

		# GENERAL
			bookings = self.booked_bookings.order(:start)
			@data[:company] = bookings[0].location.company.name
			@data[:url] = bookings[0].location.company.web_address
			@data[:signature] = bookings[0].location.company.company_setting.signature
			@data[:type] = 'image/png'
      if bookings[0].location.company.logo.email.url.include? "logo_vacio"
        @data[:logo] = Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
      else
        @data[:logo] = Base64.encode64(File.read(bookings[0].location.company.logo.email.url))
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

			@agenda = '<div>Ingresa con tu cuenta en <a href="' + helper.my_agenda_url + '"><b>tu agenda</b></a> para agendar y editar las sesiones del servicio. Si no tienes cuenta, crea una  <a href="' + helper.new_user_session_url + '"><b>acá</b></a>, o comunícate con la empresa prestadora del servicio para agendar las sesiones restantes.</div>';

			@user[:user_table] = @user_table
			@user[:agenda] = @agenda

			@data[:user] = @user

		# LOCATION
			@locations = []
			@location = {}
			@location[:name] = bookings[0].location.name
			@location[:client_name] = bookings[0].client.first_name + ' ' + bookings[0].client.last_name

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

			location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: bookings[0].location), receptor_type: 1).select(:email).distinct
			if bookings[0].web_origin
				location_emails = location_emails.where(new_web: true)
			else
				location_emails = location_emails.where(new: true)
			end
			location_emails.each do |local|
				@location[:email] = local.email
				@locations << @location
			end

			@data[:locations] = @locations

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

      providers_ids.each do |id|
        provider = ServiceProvider.find(id)
        emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: provider), receptor_type: 2, summary: false).select(:email).distinct
        emails.each do |email|
          @staff = {}
          @staff[:name] = provider.public_name
          @staff[:email] = email.email

          provider_bookings = self.booked_bookings.where(service_provider: provider).order(:start)
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

		# Company
			@companies = []
			@company = {}
			@company[:name] = bookings[0].location.company.name
			@company[:client_name] = bookings[0].client.first_name + ' ' + bookings[0].client.last_name

			@company_table = ''
			bookings.each do |book|
				@company_table += '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;">' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + book.service.name + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + I18n.l(book.start) + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + if book.notes.blank? then '' else book.notes end + '</td>' +
						'<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + if book.company_comment.blank? then '' else book.company_comment end + '</td>' +
					'</tr>'
			end
			@company[:company_table] = @company_table

			company_emails = NotificationEmail.where(company: bookings[0].location.company, receptor_type: 0).select(:email).distinct
			if bookings[0].web_origin
				company_emails = company_emails.where(new_web: true)
			else
				company_emails = company_emails.where(new: true)
			end
			company_emails.each do |company|
				@company[:email] = company.email
				@companies << @company
			end

			@data[:companies] = @companies

		if bookings.order(:start).first.start > Time.now - eval(ENV["TIME_ZONE_OFFSET"])
			BookingMailer.sessions_booking_mail(@data)
		end
	end




end
