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
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
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
					:name => 'SERVICENAME',
					:content => book_info.service.name
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
						:name => 'COMPANYNAME',
						:content => book_info.service_provider.company.name
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
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
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
					:name => 'SERVICENAME',
					:content => book_info.service.name
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
						:name => 'COMPANYNAME',
						:content => book_info.service_provider.company.name
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
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
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
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'SIGNATURE',
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br />') end
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
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
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
					:name => 'SERVICENAME',
					:content => book_info.service.name
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
						:name => 'COMPANYNAME',
						:content => book_info.service_provider.company.name
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
					:name => 'SERVICEPROVIDER',
					:content => book_info.service_provider.public_name
				},
				{
					:name => 'CLIENTNAME',
					:content => book_info.client.first_name + ' ' + book_info.client.last_name
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
					:name => 'SERVICENAME',
					:content => book_info.service.name
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
						:name => 'COMPANYNAME',
						:content => book_info.service_provider.company.name
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
end
