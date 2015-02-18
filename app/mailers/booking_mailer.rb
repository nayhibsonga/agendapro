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
			:to => [],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.service_provider.company.web_address
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
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
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
		if book_info.location.company.logo_url
			message[:images] = [{
							:type => MIME::Types.type_for(book_info.location.company.logo_url).first.content_type,
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
						}]
		end

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# Notificacion service provider
		if book_info.service_provider.get_booking_configuration_email == 0
			message[:to] << {
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			message[:merge_vars] << {
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank? and book_info.location.get_booking_configuration_email == 0
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
			message[:global_merge_vars][0] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}
		end

		# Notificacion cliente
		if book_info.send_mail
			message[:to] << {
					:email => book_info.client.email,
					:name => book_info.client.first_name + ' ' + book_info.client.last_name,
					:type => 'to'
				}
			message[:merge_vars] << {
				:rcpt => book_info.client.email,
				:vars => [
					{
						:name => 'LOCALADDRESS',
						:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
					},
					{
						:name => 'LOCATIONPHONE',
						:content => number_to_phone(book_info.location.phone)
					},
					{
						:name => 'EDIT',
						:content => booking_edit_url(:confirmation_code => book_info.confirmation_code)
					},
					{
						:name => 'CANCEL',
						:content => booking_cancel_url(:confirmation_code => book_info.confirmation_code)
					},
					{
						:name => 'CLIENT',
						:content => true
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
		template_name = 'Update Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Reserva Actualizada en ' + book_info.service_provider.company.name,
			:to => [],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.service_provider.company.web_address
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
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
				},
				{
					:name => 'OLD_START',
					:content => l(old_start)
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

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			message[:images] = [{
							:type => MIME::Types.type_for(book_info.location.company.logo_url).first.content_type,
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
						}]
		end

		# Notificacion service provider
		if book_info.service_provider.get_booking_configuration_email == 0
			message[:to] << {
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			message[:merge_vars] << {
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank? and book_info.location.get_booking_configuration_email == 0
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
			message[:global_merge_vars][0] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}
		end

		# Notificacion cliente
		if book_info.send_mail
			message[:to] << {
				:email => book_info.client.email,
				:name => book_info.client.first_name + ' ' + book_info.client.last_name,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.client.email,
				:vars => [
					{
						:name => 'LOCALADDRESS',
						:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
					},
					{
						:name => 'LOCATIONPHONE',
						:content => number_to_phone(book_info.location.phone)
					},
					{
						:name => 'EDIT',
						:content => booking_edit_url(:confirmation_code => book_info.confirmation_code)
					},
					{
						:name => 'CANCEL',
						:content => booking_cancel_url(:confirmation_code => book_info.confirmation_code)
					},
					{
						:name => 'CLIENT',
						:content => true
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
		template_name = 'Confirm Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Reserva Confirmada de ' + book_info.client.first_name + ' ' + book_info.client.last_name,
			:to => [],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'LOCALADDRESS',
					:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
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
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
				},
				{
					:name => 'COMPANYNAME',
					:content => book_info.service_provider.company.name
				},
				{
					:name => 'URL',
					:content => book_info.service_provider.company.web_address
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

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			message[:images] = [{
							:type => MIME::Types.type_for(book_info.location.company.logo_url).first.content_type,
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
						}]
		end

		# Notificacion service provider
		if book_info.service_provider.get_booking_configuration_email == 0
			message[:to] << {
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			message[:merge_vars] << {
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank? and book_info.location.get_booking_configuration_email == 0
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
			message[:global_merge_vars][0] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
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
		template_name = 'Cancel Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Reserva Cancelada en ' + book_info.service_provider.company.name,
			:to => [],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.service_provider.company.web_address
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
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
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

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			message[:images] = [{
							:type => MIME::Types.type_for(book_info.location.company.logo_url).first.content_type,
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
						}]
		end

		# Notificacion service provider
		if book_info.service_provider.get_booking_configuration_email == 0
			message[:to] << {
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			message[:merge_vars] << {
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
					]
				}
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank? and book_info.location.get_booking_configuration_email == 0
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
			message[:global_merge_vars][0] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}
		end

		# Notificacion cliente
		if book_info.send_mail
			if book_info.payed_booking.nil?
				message[:to] << {
					:email => book_info.client.email,
					:name => book_info.client.first_name + ' ' + book_info.client.last_name,
					:type => 'to'
				}
				message[:merge_vars] << {
					:rcpt => book_info.client.email,
					:vars => [
						{
							:name => 'LOCALADDRESS',
							:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
						},
						{
							:name => 'LOCATIONPHONE',
							:content => number_to_phone(book_info.location.phone)
						},
						{
							:name => 'EDIT',
							:content => booking_edit_url(:confirmation_code => book_info.confirmation_code)
						},
						{
							:name => 'CANCEL',
							:content => booking_cancel_url(:confirmation_code => book_info.confirmation_code)
						},
						{
							:name => 'CLIENT',
							:content => true
						},
						{
							:name => 'PAYED',
							:content => "true"
						}
					]
				}
			end
			message[:to] << {
				:email => book_info.client.email,
				:name => book_info.client.first_name + ' ' + book_info.client.last_name,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.client.email,
				:vars => [
					{
						:name => 'CLIENTNAME',
						:content => book_info.client.first_name + ' ' + book_info.client.last_name
					},
					{
						:name => 'LOCATIONPHONE',
						:content => number_to_phone(book_info.location.phone)
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
		template_name = 'Booking Reminder'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => book_info.service_provider.company.name,
			:subject => 'Recuerda tu Reserva en ' + book_info.service_provider.company.name,
			:to => [],
			:headers => { 'Reply-To' => book_info.service_provider.notification_email },
			:global_merge_vars => [
				{
					:name => 'URL',
					:content => book_info.service_provider.company.web_address
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
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
				}
			],
			:merge_vars => [],
			:tags => ['booking', 'remind_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			message[:images] = [{
							:type => MIME::Types.type_for(book_info.location.company.logo_url).first.content_type,
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
						}]
		end

		# Notificacion service provider
		if book_info.service_provider.get_booking_configuration_email == 0
			message[:to] << {
				  :email => book_info.service_provider.notification_email,
				  :type => 'to'
				}
			message[:merge_vars] << {
				  :rcpt => book_info.service_provider.notification_email,
				  :vars => [
						{
							:name => 'COMPANYCOMMENT',
							:content => book_info.company_comment
						}
				  ]
				}
		end

		# Email notificacion local
		if book_info.location.notification and !book_info.location.email.blank? and book_info.location.get_booking_configuration_email == 0
			message[:to] << {
				:email => book_info.location.email,
				:type => 'to'
			}
			message[:merge_vars] << {
				:rcpt => book_info.location.email,
				:vars => [
					{
						:name => 'COMPANYCOMMENT',
						:content => book_info.company_comment
					}
				]
			}
			message[:global_merge_vars][0] = {
						:name => 'SERVICEPROVIDER',
						:content => book_info.location.name
					}
		end

		# Notificacion cliente
		if book_info.send_mail
			message[:to] << {
			  :email => book_info.client.email,
			  :name => book_info.client.first_name + ' ' + book_info.client.last_name,
			  :type => 'to'
			}
			message[:merge_vars] << {
			  :rcpt => book_info.client.email,
			  :vars => [
					{
						:name => 'LOCALADDRESS',
						:content => book_info.location.address + " - " + District.find(book_info.location.district_id).name
					},
					{
						:name => 'LOCATIONPHONE',
						:content => number_to_phone(book_info.location.phone)
					},
					{
						:name => 'EDIT',
						:content => booking_edit_url(:confirmation_code => book_info.confirmation_code)
					},
					{
						:name => 'CANCEL',
						:content => booking_cancel_url(:confirmation_code => book_info.confirmation_code)
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

	def booking_summary (booking_data, booking_summary, today_schedule)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

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
				}
			],
			:tags => ['booking', 'booking_summary'],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		# => Logo empresa
		if booking_data[:logo]
			message[:images] = [{
							:type => MIME::Types.type_for(booking_data[:logo]).first.content_type,
							:name => 'LOGO',
							:content => Base64.encode64(File.read('public' + booking_data[:logo].to_s))
						}]
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
	#Correo de comprobante de pago para el cliente
	def book_payment_mail (payed_booking)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key
		# => Template
		template_name = 'Payment'
		template_content = []

		owner = User.find_by_company_id(payed_booking.booking.location.company.id)
		client = payed_booking.booking.client

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => payed_booking.booking.service_provider.company.name,
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
					:content => payed_booking.booking.location.company.name
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
					:name => 'EDIT',
					:content => booking_edit_url(:confirmation_code => payed_booking.booking.confirmation_code)
				},
				{
					:name => 'CANCEL',
					:content => booking_cancel_url(:confirmation_code => payed_booking.booking.confirmation_code)
				}

			],
			:tags => ['payment'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
				},
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		# => Metadata
		async = false
		send_at = DateTime.now

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise

	end


	#Comprobante de pago para la empresa
	def book_payment_company_mail (payed_booking)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key
		# => Template
		template_name = 'Payment'
		template_content = []

		owner = User.find_by_company_id(payed_booking.booking.location.company.id)
		#email = payed_booking.booking.location.company.company_setting.email
		client = payed_booking.booking.client

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
					:content => payed_booking.booking.location.company.name
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
				}
			],
			:tags => ['payment'],
			:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
				},
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		# => Metadata
		async = false
		send_at = DateTime.now

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise

	end

	#Comprobante de pago para la empresa
	def cancel_payment_mail (payed_booking, target)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key
		# => Template
		template_name = 'Payment'
		template_content = []

		owner = User.find_by_company_id(payed_booking.booking.location.company.id)
		#email = payed_booking.booking.location.company.company_setting.email
		client = payed_booking.booking.client

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
					}
				],
				:tags => ['payment'],
				:images => [
					{
						:type => 'image/png',
						:name => 'company_img.jpg',
						:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
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
						:content => payed_booking.booking.location.company.name
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
						:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
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
						:content => payed_booking.booking.location.company.name
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
						:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
					},
					{
						:type => 'image/png',
						:name => 'LOGO',
						:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
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
