class BookingMailer < Base::CustomMailer

	include ActionView::Helpers::NumberHelper

	def book_service_mail (book_info)
		# => Template
		template_name = 'Booking'
		template_content = []

		sessions_ratio = ""

		if book_info.is_session && !book_info.session_booking_id.nil?
			session_index = 1
			Booking.where(:session_booking_id => book_info.session_booking_id, :is_session_booked => true).order('start asc').each do |b|
				if b.id == book_info.id
				  break
				else
				  session_index = session_index + 1
				end
			end

			sessions_ratio = "(Sesión " + session_index.to_s + " de " + book_info.session_booking.sessions_amount.to_s + ")"
		end

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Nueva Reserva en ' + book_info.service_provider.company.name,
			:to => [],
			:headers => { 'Reply-To' => book_info.location.email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.location.get_web_address
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => book_info.location.company.company_setting.signature
				},
				{
					:name => 'DOMAIN',
					:content => book_info.location.company.country.domain
				},
				{
					:name => 'SESSIONSRATIO',
					:content => sessions_ratio
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'new_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			],
			:attachments => [
				{
					:type => 'text/calendar',
					:name => book_info.service.name + ' - ' + book_info.service_provider.company.name + '.ics',
					:content => Base64.encode64(book_info.generate_ics.export())
				}
			]
		}

		# => Logo empresa
		if !book_info.location.company.logo.email.url.include? "logo_vacio"
			message[:images] = [{
							:type => 'image/png',
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo.email.url.to_s))
						}]
		end

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		second_address = ''
		if !book_info.location.second_address.blank?
			second_address = ", " + book_info.location.second_address
		end

		# Notificacion cliente
		if book_info.send_mail
			message[:to] = [{
								:email => book_info.client.email,
								:name => book_info.client.first_name + ' ' + book_info.client.last_name,
								:type => 'to'
							}]
			message[:merge_vars] = [{
							:rcpt => book_info.client.email,
							:vars => [
								{
									:name => 'LOCALADDRESS',
									:content => book_info.location.address + second_address + " - " + District.find(book_info.location.district_id).name
								},
								{
									:name => 'LOCATIONPHONE',
									:content => number_to_phone(book_info.location.phone)
								},
								{
									:name => 'CLIENT',
									:content => true
								}
							]
						}]

			if book_info.location.company.company_setting.can_edit && book_info.service.online_booking && book_info.service_provider.online_booking
				message[:merge_vars][0][:vars] << {
					:name => 'EDIT',
					:content => book_info.marketplace_origin ? book_info.marketplace_url('edit') : booking_edit_url(:confirmation_code => book_info.confirmation_code)
				}
			end
			if book_info.location.company.company_setting.can_cancel
				message[:merge_vars][0][:vars] << {
					:name => 'CANCEL',
					:content => book_info.marketplace_origin ? book_info.marketplace_url('cancel') : booking_cancel_url(:confirmation_code => book_info.confirmation_code)
				}
			end


			client_template_name = template_name
			if book_info.marketplace_origin
				client_template_name = 'Booking - Marketplace'
			end

			# => Send mail
			send_mail(client_template_name, template_content, message)
		end

		# Notificacion service provider
		providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: book_info.service_provider), receptor_type: 2).select(:email).distinct
		if book_info.web_origin
			providers_emails = providers_emails.where(new_web: true)
		else
			providers_emails = providers_emails.where(new: true)
		end
		providers_emails.each do |provider|
			message[:to] = [{
					:email => provider.email,
					:type => 'bcc'
				}]
			message[:merge_vars] = [{
					:rcpt => provider.email,
					:vars => [
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion local
		location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: book_info.location), receptor_type: 1).select(:email).distinct
		if book_info.web_origin
			location_emails = location_emails.where(new_web: true)
		else
			location_emails = location_emails.where(new: true)
		end
		location_emails.each do |local|
			message[:to] = [{
							:email => local.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => local.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion compañia
		company_emails = NotificationEmail.where(company: book_info.location.company, receptor_type: 0).select(:email).distinct
		if book_info.web_origin
			company_emails = company_emails.where(new_web: true)
		else
			company_emails = company_emails.where(new: true)
		end
		company_emails.each do |company|
			message[:to] = [{
							:email => company.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => company.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.company.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end
	end

	def update_booking (book_info, old_start)
		# => Template
		template_name = 'Update Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Reserva Actualizada en ' + book_info.service_provider.company.name,
			:to => [],
			:headers => { 'Reply-To' => book_info.location.email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.location.get_web_address
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => book_info.location.company.company_setting.signature
				},
				{
					:name => 'OLD_START',
					:content => l(old_start)
				},
				{
					:name => 'DOMAIN',
					:content => book_info.location.company.country.domain
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'edit_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			],
			:attachments => [
				{
					:type => 'text/calendar',
					:name => book_info.service.name + ' - ' + book_info.service_provider.company.name + '.ics',
					:content => Base64.encode64(book_info.generate_ics.export())
				}
			]
		}

		# => Logo empresa
		if !book_info.location.company.logo.email.url.include? "logo_vacio"
			message[:images] = [{
							:type => 'image/png',
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo.email.url.to_s))
						}]
		end

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		second_address = ''
		if !book_info.location.second_address.blank?
			second_address = ", " + book_info.location.second_address
		end

		# Notificacion cliente
		if book_info.send_mail
			message[:to] = [{
							:email => book_info.client.email,
							:name => book_info.client.first_name + ' ' + book_info.client.last_name,
							:type => 'to'
						}]
			message[:merge_vars] = [{
							:rcpt => book_info.client.email,
							:vars => [
								{
									:name => 'LOCALADDRESS',
									:content => book_info.location.address + second_address + " - " + District.find(book_info.location.district_id).name
								},
								{
									:name => 'LOCATIONPHONE',
									:content => number_to_phone(book_info.location.phone)
								},
								{
									:name => 'CLIENT',
									:content => true
								}
							]
						}]

			if book_info.location.company.company_setting.can_edit && book_info.service.online_booking && book_info.service_provider.online_booking
				message[:merge_vars][0][:vars] << {
					:name => 'EDIT',
					:content => book_info.marketplace_origin ? book_info.marketplace_url('edit') : booking_edit_url(:confirmation_code => book_info.confirmation_code)
				}
			end
			if book_info.location.company.company_setting.can_cancel
				message[:merge_vars][0][:vars] << {
					:name => 'CANCEL',
					:content => book_info.marketplace_origin ? book_info.marketplace_url('cancel') : booking_cancel_url(:confirmation_code => book_info.confirmation_code)
				}
			end

			client_template_name = template_name
			if book_info.marketplace_origin
				client_template_name = 'Update Booking - Marketplace'
			end

			# => Send mail
			send_mail(client_template_name, template_content, message)
		end

		# Notificacion service provider
		providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: book_info.service_provider), receptor_type: 2).select(:email).distinct
		if book_info.web_origin
			providers_emails = providers_emails.where(modified_web: true)
		else
			providers_emails = providers_emails.where(modified: true)
		end
		providers_emails.each do |provider|
			message[:to] = [{
								:email => provider.email,
								:type => 'bcc'
							}]
			message[:merge_vars] = [{
								:rcpt => provider.email,
								:vars => [
									{
										:name => 'COMPANYCOMMENT',
										:content => book_info.company_comment
									}
								]
							}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion local
		location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: book_info.location), receptor_type: 1).select(:email).distinct
		if book_info.web_origin
			location_emails = location_emails.where(modified_web: true)
		else
			location_emails = location_emails.where(modified: true)
		end
		location_emails.each do |local|
			message[:to] = [{
							:email => local.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => local.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion compañia
		company_emails = NotificationEmail.where(company: book_info.location.company, receptor_type: 0).select(:email).distinct
		if book_info.web_origin
			company_emails = company_emails.where(modified_web: true)
		else
			company_emails = company_emails.where(modified: true)
		end
		company_emails.each do |company|
			message[:to] = [{
							:email => company.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => company.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.company.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end
	end

	def confirm_booking (book_info)
		# => Template
		template_name = 'Confirm Booking'
		template_content = []

		second_address = ''
		if !book_info.location.second_address.blank?
			second_address = ", " + book_info.location.second_address
		end

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Reserva Confirmada de ' + book_info.client.first_name + ' ' + book_info.client.last_name,
			:to => [],
			:headers => { 'Reply-To' => book_info.location.email },
			:global_merge_vars => [
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'LOCALADDRESS',
					:content => book_info.location.address + second_address + " - " + District.find(book_info.location.district_id).name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => book_info.location.company.company_setting.signature
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'URL',
					:content => book_info.location.get_web_address
				},
				{
					:name => 'DOMAIN',
					:content => book_info.location.company.country.domain
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'edit_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		# => Logo empresa
		if !book_info.location.company.logo.email.url.include? "logo_vacio"
			message[:images] = [{
							:type => 'image/png',
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo.email.url.to_s))
						}]
		end

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# Notificacion service provider
		providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: book_info.service_provider), receptor_type: 2).select(:email).distinct
		if book_info.web_origin
			providers_emails = providers_emails.where(confirmed_web: true)
		else
			providers_emails = providers_emails.where(confirmed: true)
		end
		providers_emails.each do |provider|
			message[:to] = [{
								:email => provider.email,
								:type => 'bcc'
							}]
			message[:merge_vars] = [{
								:rcpt => provider.email,
								:vars => [
									{
										:name => 'COMPANYCOMMENT',
										:content => book_info.company_comment
									}
								]
							}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion local
		location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: book_info.location), receptor_type: 1).select(:email).distinct
		if book_info.web_origin
			location_emails = location_emails.where(confirmed_web: true)
		else
			location_emails = location_emails.where(confirmed: true)
		end
		location_emails.each do |local|
			message[:to] = [{
							:email => local.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => local.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion compañia
		company_emails = NotificationEmail.where(company: book_info.location.company, receptor_type: 0).select(:email).distinct
		if book_info.web_origin
			company_emails = company_emails.where(confirmed_web: true)
		else
			company_emails = company_emails.where(confirmed: true)
		end
		company_emails.each do |company|
			message[:to] = [{
							:email => company.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => company.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.company.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end
	end

	def cancel_booking (book_info)
		# => Template
		template_name = 'Cancel Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Reserva Cancelada en ' + book_info.service_provider.company.name,
			:to => [],
			:headers => { 'Reply-To' => book_info.location.email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.location.get_web_address
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => book_info.location.company.company_setting.signature
				},
				{
					:name => 'DOMAIN',
					:content => book_info.location.company.country.domain
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'cancel_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		# => Logo empresa
		if !book_info.location.company.logo.email.url.include? "logo_vacio"
			message[:images] = [{
							:type => 'image/png',
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo.email.url.to_s))
						}]
		end

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		second_address = ''
		if !book_info.location.second_address.blank?
			second_address = ", " + book_info.location.second_address
		end

		# Notificacion cliente
		if book_info.send_mail
			message[:to] = [{
							:email => book_info.client.email,
							:name => book_info.client.first_name + ' ' + book_info.client.last_name,
							:type => 'to'
						}]
			mergeVars = {
				:rcpt => book_info.client.email,
				:vars => [
					{
						:name => 'LOCALADDRESS',
						:content => book_info.location.address + second_address + " - " + District.find(book_info.location.district_id).name
					},
					{
						:name => 'LOCATIONPHONE',
						:content => number_to_phone(book_info.location.phone)
					},
					{
						:name => 'CLIENT',
						:content => true
					}
				]
			}
			if !book_info.payed_booking.nil?
				mergeVars[:vars] << {
							:name => 'PAYED',
							:content => "true"
						}
			end
			message[:merge_vars] = [mergeVars]

			client_template_name = template_name
			if book_info.marketplace_origin
				client_template_name = 'Cancel Booking - Marketplace'
			end

			# => Send mail
			send_mail(client_template_name, template_content, message)
		end

		# Notificacion service provider
		providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: book_info.service_provider), receptor_type: 2).select(:email).distinct
		if book_info.web_origin
			providers_emails = providers_emails.where(canceled_web: true)
		else
			providers_emails = providers_emails.where(canceled: true)
		end
		providers_emails.each do |provider|
			message[:to] = [{
								:email => provider.email,
								:type => 'bcc'
							}]
			message[:merge_vars] = [{
								:rcpt => provider.email,
								:vars => [
									{
										:name => 'COMPANYCOMMENT',
										:content => book_info.company_comment
									}
								]
							}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion local
		location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: book_info.location), receptor_type: 1).select(:email).distinct
		if book_info.web_origin
			location_emails = location_emails.where(canceled_web: true)
		else
			location_emails = location_emails.where(canceled: true)
		end
		location_emails.each do |local|
			message[:to] = [{
							:email => local.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => local.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion compañia
		company_emails = NotificationEmail.where(company: book_info.location.company, receptor_type: 0).select(:email).distinct
		if book_info.web_origin
			company_emails = company_emails.where(canceled_web: true)
		else
			company_emails = company_emails.where(canceled: true)
		end
		company_emails.each do |company|
			message[:to] = [{
							:email => company.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => company.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.company.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end
	end

	def book_reminder_mail (book_info)
		# => Template
		template_name = 'Booking Reminder'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Confirma tu reserva en ' + book_info.service_provider.company.name,
			:to => [],
			:headers => { 'Reply-To' => book_info.location.email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.location.get_web_address
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => book_info.location.company.company_setting.signature
				},
				{
					:name => 'DOMAIN',
					:content => book_info.location.company.country.domain
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'remind_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				},
				{
					:type => 'image/png',
					:name => 'ARROW',
					:content => Base64.encode64(File.read('app/assets/ico/email/flecha_verde.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if !book_info.location.company.logo.email.url.include? "logo_vacio"
			message[:images][0] = {
							:type => 'image/png',
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo.email.url.to_s))
						}
		end

		second_address = ''
		if !book_info.location.second_address.blank?
			second_address = ", " + book_info.location.second_address
		end

		# Notificacion cliente
		if book_info.send_mail
			message[:to] = [{
						  :email => book_info.client.email,
						  :name => book_info.client.first_name + ' ' + book_info.client.last_name,
						  :type => 'to'
						}]
			message[:merge_vars] = [{
						  :rcpt => book_info.client.email,
						  :vars => [
								{
									:name => 'LOCALADDRESS',
									:content => book_info.location.address + second_address + " - " + District.find(book_info.location.district_id).name
								},
								{
									:name => 'LOCATIONPHONE',
									:content => number_to_phone(book_info.location.phone)
								},
								{
									:name => 'CONFIRM',
									:content => confirm_booking_url(:confirmation_code => book_info.confirmation_code)
								},
								{
									:name => 'CLIENT',
									:content => true
								}
						  ]
						}]

			if book_info.location.company.company_setting.can_edit && book_info.service.online_booking && book_info.service_provider.online_booking
				message[:merge_vars][0][:vars] << {
					:name => 'EDIT',
					:content => book_info.marketplace_origin ? book_info.marketplace_url('edit') : booking_edit_url(:confirmation_code => book_info.confirmation_code)
				}
			end
			if book_info.location.company.company_setting.can_cancel
				message[:merge_vars][0][:vars] << {
					:name => 'CANCEL',
					:content => book_info.marketplace_origin ? book_info.marketplace_url('cancel') : booking_cancel_url(:confirmation_code => book_info.confirmation_code)
				}
			end

			client_template_name = template_name
			if book_info.marketplace_origin
				client_template_name = 'Booking Reminder - Marketplace'
			end

			# => Send mail
			send_mail(client_template_name, template_content, message)
		end

		# New subject
		message[:subject] = 'Recuerda tu reserva en ' + book_info.service_provider.company.name

		# Remove arrow
		message[:images].pop

		# Notificacion service provider
		providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: book_info.service_provider), company_id: Company.where(active: true), receptor_type: 2, summary: false).select(:email).distinct
		providers_emails.each do |provider|
			message[:to] = [{
								:email => provider.email,
								:type => 'bcc'
							}]
			message[:merge_vars] = [{
								:rcpt => provider.email,
								:vars => [
									{
										:name => 'COMPANYCOMMENT',
										:content => book_info.company_comment
									}
								]
							}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion local
		location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: book_info.location), company_id: Company.where(active: true), receptor_type: 1, summary: false).select(:email).distinct
		location_emails.each do |local|
			message[:to] = [{
							:email => local.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => local.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion compañia
		company_emails = NotificationEmail.where(company_id: Company.where(id: book_info.location.company.id, active: true), receptor_type: 0, summary: false).select(:email).distinct
		company_emails.each do |company|
			message[:to] = [{
							:email => company.email,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => company.email,
							:vars => [
								{
									:name => 'COMPANYCOMMENT',
									:content => book_info.company_comment
								}
							]
						}]
			message[:global_merge_vars][3] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.company.name
					}

			# => Send mail
			send_mail(template_name, template_content, message)
		end
	end

	def multiple_booking_reminder (data)
		# => Template
		template_name = data[:marketplace] ? 'Confirm Multiple - Marketplace' : 'Multiple Booking Reminder'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => data[:company_name],
			:subject => 'Confirma tus reservas en ' + data[:company_name],
			:to => [],
			:headers => { 'Reply-To' => data[:reply_to] },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => data[:url]
				},
				{
					:name => 'COMPANYNAME',
					:content => data[:company_name]
				},
				{
					:name => 'SIGNATURE',
					:content => data[:signature]
				},
				{
					:name => 'DOMAIN',
					:content => data[:domain]
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'new_booking'],
			:images => [
				{
					:type => data[:type],
					:name => 'LOGO',
					:content => data[:logo]
				}
			]
		}

		# Notificacion cliente
		if data[:user][:send_mail]
			message[:to] = [{
								:email => data[:user][:email],
								:name => data[:user][:name],
								:type => 'to'
							}]
			message[:merge_vars] = [{
							:rcpt => data[:user][:email],
							:vars => [
								{
									:name => 'LOCALADDRESS',
									:content => data[:user][:where]
								},
								{
									:name => 'LOCATIONPHONE',
									:content => number_to_phone(data[:user][:phone])
								},
								{
									:name => 'BOOKINGS',
									:content => data[:user][:user_table]
								},
								{
									:name => 'CLIENTNAME',
									:content => data[:user][:name]
								},
								{
									:name => 'CLIENT',
									:content => true
								},
								{
									:name => 'CANCELALL',
									:content => data[:user][:cancel_all]
								},
								{
									:name => 'CONFIRMALL',
									:content => data[:user][:confirm_all]
								}
							]
						}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end
	end

	def booking_summary (booking_data, booking_summary, today_schedule)
		# => Template
		template_name = 'Booking Summary'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Resumen de Reservas',
			:to => [
				{
					:email => booking_data[:to],
					:type => 'to'
				}
			],
			:global_merge_vars => [
				{
					:name => 'COMPANYNAME',
					:content => booking_data[:company]
				},
				{
					:name => 'URL',
					:content => booking_data[:url]
				},
				{
					:name => 'NAME',
					:content => booking_data[:name]
				},
				{
					:name => 'SUMMARY',
					:content => booking_summary
				},
				{
					:name => 'TODAY',
					:content => today_schedule
				},
				{
					:name => 'DOMAIN',
					:content => booking_data[:domain]
				}
			],
			:tags => ['booking', 'booking_summary'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read(booking_data[:logo].to_s))
				}
			]
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	def multiple_booking_mail (data)
		# => Template
		template_name = data[:marketplace] ? 'Multiple Bookings - Marketplace' : 'Multiple Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => data[:company_name],
			:subject => 'Nueva Reserva en ' + data[:company_name],
			:to => [],
			:headers => { 'Reply-To' => data[:reply_to] },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => data[:url]
				},
				{
					:name => 'COMPANYNAME',
					:content => data[:company_name]
				},
				{
					:name => 'SIGNATURE',
					:content => data[:signature]
				},
				{
					:name => 'DOMAIN',
					:content => data[:domain]
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'new_booking'],
			:images => [
				{
					:type => data[:type],
					:name => 'LOGO',
					:content => data[:logo]
				}
			]
		}

		# Notificacion cliente
		if data[:user][:send_mail]
			message[:to] = [{
								:email => data[:user][:email],
								:name => data[:user][:name],
								:type => 'to'
							}]
			message[:merge_vars] = [{
							:rcpt => data[:user][:email],
							:vars => [
								{
									:name => 'LOCALADDRESS',
									:content => data[:user][:where]
								},
								{
									:name => 'LOCATIONPHONE',
									:content => number_to_phone(data[:user][:phone])
								},
								{
									:name => 'BOOKINGS',
									:content => data[:user][:user_table]
								},
								{
									:name => 'CLIENTNAME',
									:content => data[:user][:name]
								},
								{
									:name => 'CLIENT',
									:content => true
								}
							]
						}]

			if data[:user][:can_cancel]
				message[:merge_vars][0][:vars] << {
					:name => 'CANCEL',
					:content => data[:user][:cancel]
				}
			end

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Notificacion service provider
		data[:provider][:array].each do |provider|
			message[:to] = [{
								:email => provider[:email],
								:type => 'bcc'
							}]
			message[:merge_vars] = [{
								:rcpt => provider[:email],
								:vars => [
									{
										:name => 'CLIENTNAME',
										:content => data[:provider][:client_name]
									},
									{
										:name => 'SERVICEPROVIDER',
										:content => provider[:name]
									},
									{
										:name => 'BOOKINGS',
										:content => provider[:provider_table]
									}
								]
							}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion local
		data[:location][:email].each do |local|
			message[:to] = [{
							:email => local,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => local,
							:vars => [
								{
									:name => 'CLIENTNAME',
									:content => data[:location][:client_name]
								},
								{
									:name => 'SERVICEPROVIDER',
									:content => data[:location][:name]
								},
								{
									:name => 'BOOKINGS',
									:content => data[:location][:location_table]
								}
							]
						}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Notificacion Empresa
		data[:company][:email].each do |company|
			message[:to] = [{
							:email => company,
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => company,
							:vars => [
								{
									:name => 'CLIENTNAME',
									:content => data[:company][:client_name]
								},
								{
									:name => 'SERVICEPROVIDER',
									:content => data[:company][:name]
								},
								{
									:name => 'BOOKINGS',
									:content => data[:company][:company_table]
								}
							]
						}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end
	end

	#Correo de comprobante de pago para el cliente
	def book_payment_mail (payed_booking)
		# => Template
		template_name = 'Payment'
		template_content = []

		owner = User.find_by_company_id(payed_booking.bookings.first.location.company.id)
		client = payed_booking.bookings.first.client

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => payed_booking.bookings.first.service_provider.company.name,
			:subject => 'Comprobante de pago en Agendapro',
			:to => [
				{
					:email => client.email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'COMPANYNAME',
					:content => payed_booking.bookings.first.location.company.name
				},
				{
					:name => 'PRICE',
					:content => payed_booking.punto_pagos_confirmation.amount
				},
				{
					:name => 'CARDNUMBER',
					:content => payed_booking.punto_pagos_confirmation.card_number
				},
				{
					:name => 'PAYORDER',
					:content => payed_booking.punto_pagos_confirmation.operation_number
				},
				{
					:name => 'AUTHNUMBER',
					:content => payed_booking.punto_pagos_confirmation.authorization_code
				},
				{
					:name => 'DATE',
					:content => payed_booking.punto_pagos_confirmation.approvement_date
				},
				{
					:name => 'CLIENT',
					:content => client.first_name + ' ' + client.last_name
				},
				{
					:name => 'DOMAIN',
					:content => payed_booking.bookings.first.location.company.country.domain
				}

			],
			:tags => ['payment']
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	#Correo de comprobante de pago para AgendaPro
	def book_payment_agendapro_mail(payed_booking)
		# => Template
		template_name = 'Payment'
		template_content = []

		owner = User.find_by_company_id(payed_booking.bookings.first.location.company.id)
		client = payed_booking.bookings.first.client

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => payed_booking.bookings.first.service_provider.company.name,
			:subject => 'Comprobante de pago en Agendapro',
			:to => [
				{
					:email => "nrossi@agendapro.cl",
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'COMPANYNAME',
					:content => payed_booking.bookings.first.location.company.name
				},
				{
					:name => 'PRICE',
					:content => payed_booking.punto_pagos_confirmation.amount
				},
				{
					:name => 'CARDNUMBER',
					:content => payed_booking.punto_pagos_confirmation.card_number
				},
				{
					:name => 'PAYORDER',
					:content => payed_booking.punto_pagos_confirmation.operation_number
				},
				{
					:name => 'AUTHNUMBER',
					:content => payed_booking.punto_pagos_confirmation.authorization_code
				},
				{
					:name => 'DATE',
					:content => payed_booking.punto_pagos_confirmation.approvement_date
				},
				{
					:name => 'CLIENT',
					:content => client.first_name + ' ' + client.last_name
				},
				{
					:name => 'DOMAIN',
					:content => payed_booking.bookings.first.location.company.country.domain
				}

			],
			:tags => ['payment'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/apple-touch-icon.png'))
				},
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	#Comprobante de pago para la empresa
	def book_payment_company_mail (payed_booking)
		# => Template
		template_name = 'Payment'
		template_content = []

		owner = User.find_by_company_id(payed_booking.bookings.first.location.company.id)
		#email = payed_booking.booking.location.company.company_setting.email
		client = payed_booking.bookings.first.client

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Comprobante de pago en Agendapro',
			:to => [
				{
					:email => owner.email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'COMPANYNAME',
					:content => payed_booking.bookings.first.location.company.name
				},
				{
					:name => 'PRICE',
					:content => payed_booking.punto_pagos_confirmation.amount
				},
				{
					:name => 'CARDNUMBER',
					:content => payed_booking.punto_pagos_confirmation.card_number
				},
				{
					:name => 'PAYORDER',
					:content => payed_booking.punto_pagos_confirmation.operation_number
				},
				{
					:name => 'AUTHNUMBER',
					:content => payed_booking.punto_pagos_confirmation.authorization_code
				},
				{
					:name => 'DATE',
					:content => payed_booking.punto_pagos_confirmation.approvement_date
				},
				{
					:name => 'DOMAIN',
					:content => payed_booking.bookings.first.location.company.country.domain
				}
			],
			:tags => ['payment'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/apple-touch-icon.png'))
				},
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	#Comprobante de pago para la empresa
	def cancel_payment_mail (payed_booking, target)
		# => Template
		template_name = 'Payment'
		template_content = []

		owner = User.find_by_company_id(payed_booking.bookings.first.location.company.id)
		#email = payed_booking.booking.location.company.company_setting.email
		client = payed_booking.bookings.first.client

		message = Hash.new

		if target == 1 #Mail al cliente
			# => Message
			message = {
				:from_email => 'no-reply@agendapro.cl',
				:from_name => 'AgendaPro',
				:subject => 'Cancelación de pago en Agendapro',
				:to => [
					{
						:email => client.email,
						:type => 'to'
					}
				],
				:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
				:global_merge_vars => [
					{
						:name => 'COMPANYNAME',
						:content => payed_booking.bookings.first.location.company.name
					},
					{
						:name => 'CANCEL',
						:content => 'true'
					},
					{
						:name => 'CLIENTCANCEL',
						:content => 'true'
					},
					{
						:name => 'CLIENT',
						:content => client.first_name + ' ' + client.last_name
					},
					{
						:name => 'PRICE',
						:content => payed_booking.punto_pagos_confirmation.amount
					},
					{
						:name => 'CARDNUMBER',
						:content => payed_booking.punto_pagos_confirmation.card_number
					},
					{
						:name => 'PAYORDER',
						:content => payed_booking.punto_pagos_confirmation.operation_number
					},
					{
						:name => 'AUTHNUMBER',
						:content => payed_booking.punto_pagos_confirmation.authorization_code
					},
					{
						:name => 'DATE',
						:content => payed_booking.punto_pagos_confirmation.approvement_date
					},
					{
						:name => 'DOMAIN',
						:content => payed_booking.bookings.first.location.company.country.domain
					}
				],
				:tags => ['payment'],
				:images => [
					{
						:type => 'image/png',
						:name => 'company_img.jpg',
						:content => Base64.encode64(File.read('app/assets/ico/apple-touch-icon.png'))
					},
					{
						:type => 'image/png',
						:name => 'LOGO',
						:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
					}
				]
			}
		elsif target == 2 #Mail a la empresa
			# => Message
			message = {
				:from_email => 'no-reply@agendapro.cl',
				:from_name => 'AgendaPro',
				:subject => 'Cancelación de pago en Agendapro',
				:to => [
					{
						:email => owner.email,
						:type => 'to'
					}
				],
				:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
				:global_merge_vars => [
					{
						:name => 'CANCEL',
						:content => 'true'
					},
					{
						:name => 'COMPANYCANCEL',
						:content => 'true'
					},
					{
						:name => 'COMPANYNAME',
						:content => payed_booking.bookings.first.location.company.name
					},
					{
						:name => 'PRICE',
						:content => payed_booking.punto_pagos_confirmation.amount
					},
					{
						:name => 'CARDNUMBER',
						:content => payed_booking.punto_pagos_confirmation.card_number
					},
					{
						:name => 'PAYORDER',
						:content => payed_booking.punto_pagos_confirmation.operation_number
					},
					{
						:name => 'AUTHNUMBER',
						:content => payed_booking.punto_pagos_confirmation.authorization_code
					},
					{
						:name => 'DATE',
						:content => payed_booking.punto_pagos_confirmation.approvement_date
					}
				],
				:tags => ['payment'],
				:images => [
					{
						:type => 'image/png',
						:name => 'company_img.jpg',
						:content => Base64.encode64(File.read('app/assets/ico/apple-touch-icon.png'))
					},
					{
						:type => 'image/png',
						:name => 'LOGO',
						:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
					}
				]
			}
		else #Mail a AgendaPro
			# => Message
			message = {
				:from_email => 'no-reply@agendapro.cl',
				:from_name => 'AgendaPro',
				:subject => 'Cancelación de pago en Agendapro',
				:to => [
					{
						:email => 'iegomez@uc.cl', #Cambiar a contacto@agendapro.cl
						:type => 'to'
					}
				],
				:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
				:global_merge_vars => [
					{
						:name => 'CANCEL',
						:content => 'true'
					},
					{
						:name => 'AGENDAPROCANCEL',
						:content => 'true'
					},
					{
						:name => 'COMPANYNAME',
						:content => payed_booking.bookings.first.location.company.name
					},
					{
						:name => 'CLIENT',
						:content => client.first_name + ' ' + client.last_name
					},
					{
						:name => 'CLIENTEMAIL',
						:content => client.email
					},
					{
						:name => 'PRICE',
						:content => payed_booking.punto_pagos_confirmation.amount
					},
					{
						:name => 'CARDNUMBER',
						:content => payed_booking.punto_pagos_confirmation.card_number
					},
					{
						:name => 'PAYORDER',
						:content => payed_booking.punto_pagos_confirmation.operation_number
					},
					{
						:name => 'AUTHNUMBER',
						:content => payed_booking.punto_pagos_confirmation.authorization_code
					},
					{
						:name => 'DATE',
						:content => payed_booking.punto_pagos_confirmation.approvement_date
					}
				],
				:tags => ['payment'],
				:images => [
					{
						:type => 'image/png',
						:name => 'company_img.jpg',
						:content => Base64.encode64(File.read('app/assets/ico/apple-touch-icon.png'))
					},
					{
						:type => 'image/png',
						:name => 'LOGO',
						:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
					}
				]
			}
		end

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	#Mail de reserva de servicio con sesiones
	def sessions_booking_mail(data)
		# => Template
		template_name = 'Sessions Bookings'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => data[:company],
			:subject => 'Nueva Reserva en ' + data[:company],
			:to => [],
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => data[:url]
				},
				{
					:name => 'COMPANYNAME',
					:content => data[:company]
				},
				{
					:name => 'SIGNATURE',
					:content => data[:signature]
				},
				{
					:name => 'DOMAIN',
					:content => data[:domain]
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'new_booking'],
			:images => [
				{
					:type => data[:type],
					:name => 'LOGO',
					:content => data[:logo]
				}
			]
		}

		# Notificacion cliente
		if data[:user][:send_mail]
			message[:to] = [{
								:email => data[:user][:email],
								:name => data[:user][:name],
								:type => 'to'
							}]
			message[:merge_vars] = [{
							:rcpt => data[:user][:email],
							:vars => [
								{
									:name => 'LOCALADDRESS',
									:content => data[:user][:where]
								},
								{
									:name => 'LOCATIONPHONE',
									:content => number_to_phone(data[:user][:phone])
								},
								{
									:name => 'BOOKINGS',
									:content => data[:user][:user_table]
								},
								{
									:name => 'AGENDA',
									:content => data[:user][:agenda]
								},
								{
									:name => 'CLIENTNAME',
									:content => data[:user][:name]
								},
								{
									:name => 'CLIENT',
									:content => true
								}
							]
						}]

			if data[:user][:can_cancel]
				message[:merge_vars][0][:vars] << {
					:name => 'CANCEL',
					:content => data[:user][:cancel]
				}
			end

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Notificacion service provider
		data[:provider][:array].each do |provider|
			message[:to] = [{
								:email => provider[:email],
								:type => 'bcc'
							}]
			message[:merge_vars] = [{
								:rcpt => provider[:email],
								:vars => [
									{
										:name => 'CLIENTNAME',
										:content => data[:provider][:client_name]
									},
									{
										:name => 'SERVICEPROVIDER',
										:content => provider[:name]
									},
									{
										:name => 'BOOKINGS',
										:content => provider[:provider_table]
									}
								]
							}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion local
		data[:locations].each do |location|
			message[:to] = [{
							:email => location[:email],
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => location[:email],
							:vars => [
								{
									:name => 'CLIENTNAME',
									:content => location[:client_name]
								},
								{
									:name => 'SERVICEPROVIDER',
									:content => location[:name]
								},
								{
									:name => 'BOOKINGS',
									:content => location[:location_table]
								}
							]
						}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end

		# Email notificacion company
		data[:companies].each do |company|
			message[:to] = [{
							:email => company[:email],
							:type => 'bcc'
						}]
			message[:merge_vars] = [{
							:rcpt => company[:email],
							:vars => [
								{
									:name => 'CLIENTNAME',
									:content => company[:client_name]
								},
								{
									:name => 'SERVICEPROVIDER',
									:content => company[:name]
								},
								{
									:name => 'BOOKINGS',
									:content => company[:company_table]
								}
							]
						}]

			# => Send mail
			send_mail(template_name, template_content, message)
		end
	end

	#Mail de reserva de sesión de admin (opción de validar)
	def admin_session_booking_mail(book_info)
		# => Template
		template_name = 'Admin Session Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Nueva Reserva en ' + book_info.service_provider.company.name,
			:to => [],
			:headers => { 'Reply-To' => book_info.location.email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.location.get_web_address
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => book_info.location.company.company_setting.signature
				},
				{
					:name => 'DOMAIN',
					:content => book_info.location.company.country.domain
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'new_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			],
			:attachments => [
				{
					:type => 'text/calendar',
					:name => book_info.service.name + ' - ' + book_info.service_provider.company.name + '.ics',
					:content => Base64.encode64(book_info.generate_ics.export())
				}
			]
		}

		# => Logo empresa
		if !book_info.location.company.logo.email.url.include? "logo_vacio"
			message[:images] = [{
							:type => 'image/png',
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo.email.url.to_s))
						}]
		end

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		second_address = ''
		if !book_info.location.second_address.blank?
			second_address = ", " + book_info.location.second_address
		end

		# Notificacion cliente
		if book_info.send_mail
			message[:to] = [{
								:email => book_info.client.email,
								:name => book_info.client.first_name + ' ' + book_info.client.last_name,
								:type => 'to'
							}]
			message[:merge_vars] = [{
							:rcpt => book_info.client.email,
							:vars => [
								{
									:name => 'LOCALADDRESS',
									:content => book_info.location.address + second_address + " - " + District.find(book_info.location.district_id).name
								},
								{
									:name => 'LOCATIONPHONE',
									:content => number_to_phone(book_info.location.phone)
								},
								{
									:name => 'VALIDATE',
									:content => validate_session_form_url(:confirmation_code => book_info.confirmation_code)
								},
								{
									:name => 'CLIENT',
									:content => true
								}
							]
						}]

			if book_info.location.company.company_setting.can_edit && book_info.service.online_booking && book_info.service_provider.online_booking
				message[:merge_vars][0][:vars] << {
					:name => 'EDIT',
					:content => book_info.marketplace_origin ? book_info.marketplace_url('edit') : booking_edit_url(:confirmation_code => book_info.confirmation_code)
				}
			end
			if book_info.location.company.company_setting.can_cancel
				message[:merge_vars][0][:vars] << {
					:name => 'CANCEL',
					:content => book_info.marketplace_origin ? book_info.marketplace_url('cancel') : booking_cancel_url(:confirmation_code => book_info.confirmation_code)
				}
			end
		end

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	#Mail de edición de sesión (depende de si es por admin o no)
	def update_session_booking_mail(booking, is_admin)
	end
end
