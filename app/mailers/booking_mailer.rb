class BookingMailer < ActionMailer::Base
	require 'mandrill'
	require 'base64'
	
	include ActionView::Helpers::NumberHelper

	def book_service_mail (book_info)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		# => Template
		template_name = 'Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Nueva Reserva en ' + book_info.service_provider.company.name,
			:to => [
				{
					:email => book_info.client.email,
					:name => book_info.client.first_name + ' ' + book_info.client.last_name,
					:type => 'to'
				},
				{
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				# {
				# 	:name => 'UNSUBSCRIBE',
				# 	:content => "Si deseas dejar de recibir emails de AgendaPro, puedes dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.client.email))}'>aquí</a>"
				# },
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'LOCALADDRESS',
					:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				}
			],
			:merge_vars => [
				{
					:rcpt => book_info.client.email,
					:vars => [
						
						{
							:name => 'NAME',
							:content => book_info.client.first_name
						},
						{
							:name => 'MESSAGE',
							:content => 'tu reserva fue recibida exitosamente'
						},
						{
							:name => 'EDIT',
							:content => "<a class='btn btn-warning' href='#{booking_edit_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 5px;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #f0ad4e;border-color: #eea236;text-decoration:none;'>Modificar Reserva</a>"
						},
						{
							:name => 'CANCEL',
							:content => "<a class='btn btn-danger' href='#{booking_cancel_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 5px;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #d9534f;border-color: #d43f3a;text-decoration:none;'>Cancelar Reserva</a>"
						},
						{
							:name => 'LOCATIONPHONE',
							:content => number_to_phone(book_info.location.phone)
						},
						{
							:name => 'WHAT',
							:content => "¿Qué reservaste?"
						},
						{
							:name => 'BOOKING',
							:content => "Resumen de tu Reserva"
						},
						{
							:name => 'HOURS',
							:content => book_info.location.company.company_setting.before_edit_booking
						}
					]
				},
				{
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'NAME',
							:content => book_info.service_provider.public_name
						},
						{
							:name => 'MESSAGE',
							:content => 'fue reservado un servicio contigo'
						},
						{
							:name => 'WHAT',
							:content => "¿Qué reservaron?"
						},
						{
							:name => 'BOOKING',
							:content => "Resumen de la Nueva Reserva"
						},
						{
							:name => 'CLIENTNAME',
							:content => book_info.client.first_name + ' ' + book_info.client.last_name
						},
						{
							:name => 'CLIENTPHONE',
							:content => number_to_phone(book_info.client.phone)
						},
						{
							:name => 'CLIENTEMAIL',
							:content => book_info.client.email
						},
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}
			],
			:tags => ['booking', 'new_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
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
		if book_info.location.company.logo_url
			company_logo = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
			message[:images] = [company_logo]
		end

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank?
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'NAME',
						:content => book_info.location.name
					},
					{
						:name => 'MESSAGE',
						:content => 'fue reservado un servicio en el Local'
					},
					{
						:name => 'WHAT',
						:content => "¿Qué reservaron?"
					},
					{
						:name => 'BOOKING',
						:content => "Resumen de la Nueva Reserva"
					},
					{
						:name => 'CLIENTNAME',
						:content => book_info.client.first_name + ' ' + book_info.client.last_name
					},
					{
						:name => 'CLIENTPHONE',
						:content => number_to_phone(book_info.client.phone)
					},
					{
						:name => 'CLIENTEMAIL',
						:content => book_info.client.email
					},
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
		end

		# => Metadata
		async = false
		send_at = DateTime.now

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end

	def update_booking (book_info, old_start)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		# => Template
		template_name = 'Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Reserva Actualizada en ' + book_info.service_provider.company.name,
			:to => [
				{
					:email => book_info.client.email,
					:name => book_info.client.first_name + ' ' + book_info.client.last_name,
					:type => 'to'
				},
				{
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				# {
				# 	:name => 'UNSUBSCRIBE',
				# 	:content => "Si deseas dejar de recibir emails de AgendaPro, puedes dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.client.email))}'>aquí</a>"
				# },
				{
					:name => 'OLD_START',
					:content => l(old_start)
				},
				{
					:name => 'LOCALADDRESS',
					:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
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
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				}
			],
			:merge_vars => [
				{
					:rcpt => book_info.client.email,
					:vars => [
						
						{
							:name => 'NAME',
							:content => book_info.client.first_name
						},
						{
							:name => 'MESSAGE',
							:content => 'tu reserva fue actualizada exitosamente'
						},
						{
							:name => 'EDIT',
							:content => "<a class='btn btn-warning' href='#{booking_edit_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #f0ad4e;border-color: #eea236;text-decoration:none;'>Modificar Reserva</a>"
						},
						{
							:name => 'CANCEL',
							:content => "<a class='btn btn-danger' href='#{booking_cancel_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #d9534f;border-color: #d43f3a;text-decoration:none;'>Cancelar Reserva</a>"
						},
						{
							:name => 'LOCATIONPHONE',
							:content => number_to_phone(book_info.location.phone)
						},
						{
							:name => 'WHAT',
							:content => "¿Qué reservaste?"
						},
						{
							:name => 'BOOKING',
							:content => "Resumen de tu Reserva"
						},
						{
							:name => 'HOURS',
							:content => book_info.location.company.company_setting.before_edit_booking
						}
					]
				},
				{
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						
						{
							:name => 'NAME',
							:content => book_info.service_provider.public_name
						},
						{
							:name => 'MESSAGE',
							:content => 'fue modificada una de tus reservas, a continuación se presentan los detalles actualizados'
						},
						{
							:name => 'WHAT',
							:content => "¿Qué reservaron?"
						},
						{
							:name => 'BOOKING',
							:content => "Resumen de la Reserva"
						},
						{
							:name => 'CLIENTNAME',
							:content => book_info.client.first_name + ' ' + book_info.client.last_name
						},
						{
							:name => 'CLIENTPHONE',
							:content => number_to_phone(book_info.client.phone)
						},
						{
							:name => 'CLIENTMAIL',
							:content => book_info.client.email
						},
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}
			],
			:tags => ['booking', 'edit_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
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

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_logo = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
			message[:images] = [company_logo]
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank?
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'NAME',
						:content => book_info.location.name
					},
					{
						:name => 'MESSAGE',
						:content => 'fue modificada una reserva, a continuación se presentan los detalles actualizados'
					},
					{
						:name => 'WHAT',
						:content => "¿Qué reservaron?"
					},
					{
						:name => 'BOOKING',
						:content => "Resumen de la Reserva"
					},
					{
						:name => 'CLIENTNAME',
						:content => book_info.client.first_name + ' ' + book_info.client.last_name
					},
					{
						:name => 'CLIENTPHONE',
						:content => number_to_phone(book_info.client.phone)
					},
					{
						:name => 'CLIENTEMAIL',
						:content => book_info.client.email
					},
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
		end

		# => Metadata
		async = false
		send_at = DateTime.now

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end

	def confirm_booking (book_info)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		# => Template
		template_name = 'Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Reserva Confirmada de ' + book_info.client.first_name + ' ' + book_info.client.last_name,
			:to => [
				{
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				# {
				# 	:name => 'UNSUBSCRIBE',
				# 	:content => "Si deseas dejar de recibir emails de AgendaPro, puedes dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.client.email))}'>aquí</a>"
				# },
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'LOCALADDRESS',
					:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				}
			],
			:merge_vars => [
				{
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'NAME',
							:content => book_info.service_provider.public_name
						},
						{
							:name => 'MESSAGE',
							:content => 'tu cliente ha confirmado la siguiente reserva'
						},
						{
							:name => 'WHAT',
							:content => "¿Qué reservaron?"
						},
						{
							:name => 'BOOKING',
							:content => "Resumen de la Reserva Confirmada"
						},
						{
							:name => 'CLIENTNAME',
							:content => book_info.client.first_name + ' ' + book_info.client.last_name
						},
						{
							:name => 'CLIENTPHONE',
							:content => number_to_phone(book_info.client.phone)
						},
						{
							:name => 'CLIENTMAIL',
							:content => book_info.client.email
						},
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}
			],
			:tags => ['booking', 'edit_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_logo = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
			message[:images] = [company_logo]
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank?
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'NAME',
						:content => book_info.location.name
					},
					{
						:name => 'MESSAGE',
						:content => 'el cliente ha confirmado la siguiente reserva'
					},
					{
						:name => 'WHAT',
						:content => "¿Qué reservaron?"
					},
					{
						:name => 'BOOKING',
						:content => "Resumen de la Reserva Confirmada"
					},
					{
						:name => 'CLIENTNAME',
						:content => book_info.client.first_name + ' ' + book_info.client.last_name
					},
					{
						:name => 'CLIENTPHONE',
						:content => number_to_phone(book_info.client.phone)
					},
					{
						:name => 'CLIENTEMAIL',
						:content => book_info.client.email
					},
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
		end

		# => Metadata
		async = false
		send_at = DateTime.now

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end

	def cancel_booking (book_info)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		# => Template
		template_name = 'Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Reserva Cancelada en ' + book_info.service_provider.company.name,
			:to => [
				{
					:email => book_info.client.email,
					:name => book_info.client.first_name + ' ' + book_info.client.last_name,
					:type => 'to'
				},
				{
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				# {
				# 	:name => 'UNSUBSCRIBE',
				# 	:content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.client.email))}'>aquí</a>."
				# },
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'LOCALADDRESS',
					:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				}
			],
			:merge_vars => [
				{
					:rcpt => book_info.client.email,
					:vars => [
						
						{
							:name => 'NAME',
							:content => book_info.client.first_name
						},
						{
							:name => 'MESSAGE',
							:content => 'tu reserva fue cancelada exitosamente'
						},
						{
							:name => 'LOCATIONPHONE',
							:content => number_to_phone(book_info.location.phone)
						},
						{
							:name => 'WHAT',
							:content => "¿Qué cancelaste?"
						},
						{
							:name => 'BOOKING',
							:content => "Resumen de tu Reserva Cancelada"
						},
						{
							:name => 'HOURS',
							:content => book_info.location.company.company_setting.before_edit_booking
						}
					]
				},
				{
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						
						{
							:name => 'NAME',
							:content => book_info.service_provider.public_name
						},
						{
							:name => 'MESSAGE',
							:content => 'fue cancelada una reserva contigo, a continuación se presentan los detalles'
						},
						{
							:name => 'WHAT',
							:content => "¿Qué cancelaron?"
						},
						{
							:name => 'BOOKING',
							:content => "Resumen de la Reserva Cancelada"
						},
						{
							:name => 'CLIENTNAME',
							:content => book_info.client.first_name + ' ' + book_info.client.last_name
						},
						{
							:name => 'CLIENTPHONE',
							:content => number_to_phone(book_info.client.phone)
						},
						{
							:name => 'CLIENTMAIL',
							:content => book_info.client.email
						},
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}
			],
			:tags => ['booking', 'cancel_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_logo = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
			message[:images] = [company_logo]
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank?
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'NAME',
						:content => book_info.location.name
					},
					{
						:name => 'MESSAGE',
						:content => 'fue cancelada una reserva, a continuación se presentan los detalles'
					},
					{
						:name => 'WHAT',
						:content => "¿Qué reservaron?"
					},
					{
						:name => 'BOOKING',
						:content => "Resumen de la Reserva Cancelada"
					},
					{
						:name => 'CLIENTNAME',
						:content => book_info.client.first_name + ' ' + book_info.client.last_name
					},
					{
						:name => 'CLIENTPHONE',
						:content => number_to_phone(book_info.client.phone)
					},
					{
						:name => 'CLIENTEMAIL',
						:content => book_info.client.email
					},
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
		end

		# => Metadata
		async = false
		send_at = DateTime.now

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end

	def book_reminder_mail (book_info)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		# => Template
		template_name = 'Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Recuerda tu Reserva en ' + book_info.service_provider.company.name,
			:to => [
				{
				  :email => book_info.client.email,
				  :name => book_info.client.first_name + ' ' + book_info.client.last_name,
				  :type => 'to'
				},
				{
				  :email => book_info.service_provider.notification_email,
				  :type => 'to'
				}
			],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				# {
				# 	:name => 'UNSUBSCRIBE',
				# 	:content => "Si deseas dejar de recibir emails de AgendaPro, puedes dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.client.email))}'>aquí</a>"
				# },
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'LOCALADDRESS',
					:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'SIGNATURE',
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
				},
				{
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				}
			],
			:merge_vars => [
				{
				  :rcpt => book_info.client.email,
				  :vars => [
					
					{
					  :name => 'NAME',
					  :content => book_info.client.first_name
					},
					{
					  :name => 'MESSAGE',
					  :content => 'recuerda tu reserva para mañana'
					},
					{
						:name => 'EDIT',
						:content => "<a class='btn btn-warning' href='#{booking_edit_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #f0ad4e;border-color: #eea236;text-decoration:none;'>Modificar Reserva</a>"
					},
					{
						:name => 'CANCEL',
						:content => "<a class='btn btn-danger' href='#{booking_cancel_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #d9534f;border-color: #d43f3a;text-decoration:none;'>Cancelar Reserva</a>"
					},
					{
						:name => 'CONFIRM',
						:content => "<a class='btn btn-agendapro-claro btn-lg' href='#{confirm_booking_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 10px 16px;margin-bottom: 0;font-size: 18px;font-weight: normal;line-height: 1.33;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 6px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: rgba(61,154,150,1);border-color: rgba(55, 133, 129, 1);text-decoration:none;'>Confirmar Reserva</a>"
					},
					{
						:name => 'LOCATIONPHONE',
						:content => number_to_phone(book_info.location.phone)
					},
					{
						:name => 'WHAT',
						:content => "¿Qué reservaste?"
					},
					{
						:name => 'BOOKING',
						:content => "Resumen de tu Reserva"
					},
					{
						:name => 'HOURS',
						:content => book_info.location.company.company_setting.before_edit_booking
					}
				  ]
				},
				{
				  :rcpt => book_info.service_provider.notification_email,
				  :vars => [
					
					{
					  :name => 'NAME',
					  :content => book_info.service_provider.public_name
					},
					{
					  :name => 'MESSAGE',
					  :content => 'Recuerda que mañana tienen una hora agendada contigo'  
					},
					{
						:name => 'WHAT',
						:content => "¿Qué reservaron?"
					},
					{
						:name => 'BOOKING',
						:content => "Resumen de la Reserva"
					},
					{
						:name => 'CLIENTNAME',
						:content => book_info.client.first_name + ' ' + book_info.client.last_name
					},
					{
						:name => 'CLIENTPHONE',
						:content => number_to_phone(book_info.client.phone)
					},
					{
						:name => 'CLIENTMAIL',
						:content => book_info.client.email
					},
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				  ]
				}
			],
			:tags => ['booking', 'remind_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_logo = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
			message[:images] = [company_logo]
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank?
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'NAME',
						:content => book_info.location.name
					},
					{
						:name => 'MESSAGE',
						:content => 'Recuerda que mañana tienen una hora agendada'
					},
					{
						:name => 'WHAT',
						:content => "¿Qué reservaron?"
					},
					{
						:name => 'BOOKING',
						:content => "Resumen de la Reserva"
					},
					{
						:name => 'CLIENTNAME',
						:content => book_info.client.first_name + ' ' + book_info.client.last_name
					},
					{
						:name => 'CLIENTPHONE',
						:content => number_to_phone(book_info.client.phone)
					},
					{
						:name => 'CLIENTEMAIL',
						:content => book_info.client.email
					},
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
		end

		# => Metadata
		async = false
		send_at = DateTime.now

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end
end