class BookingMailer < ActionMailer::Base
	require 'mandrill'
	require 'base64'
	
	def book_service_mail (book_info)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		# => Template
		template_name = 'Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Nueva Reserva en ' + book_info.service_provider.company.name,
			:to => [
				{
					:email => book_info.email,
					:name => book_info.last_name + ', ' + book_info.first_name,
					:type => 'to'
				},
				{
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => "contacto@agendapro.cl" },
			:global_merge_vars => [
				{
					:name => 'UNSUBSCRIBE',
					:content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.email))}'>aquí</a>."
				},
				{
					:name => 'LNAME',
					:content => book_info.last_name
				},
				{
					:name => 'FNAME',
					:content => book_info.first_name
				},
				{
					:name => 'LOCALNAME',
					:content => book_info.location.name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'SERVICEPRICE',
					:content => if book_info.service.show_price && book_info.service.price && book_info.service.price > 0 then '$' + book_info.service.price.to_s else 'Consultar en Local' end
				},
				{
					:name => 'SERVICEDURATION',
					:content => book_info.service.duration
				},
				{
					:name => 'EMAIL',
					:content => book_info.email
				},
				{
					:name => 'PHONE',
					:content => book_info.phone
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'BEND',
					:content => l(book_info.end)
				},
				{
					:name => 'SIGNATURE',
					:content => book_info.location.company.company_setting.signature
				}
			],
			:merge_vars => [
				{
					:rcpt => book_info.email,
					:vars => [
						{
							:name => 'RMESSAGE',
							:content => 'Gracias'
						},
						{
							:name => 'NAME',
							:content => book_info.first_name
						},
						{
							:name => 'MESSAGE',
							:content => 'Su servicio fue agendado correctamente.'
						},
						{
							:name => 'EDIT',
							:content => "<a class='btn btn-warning' href='#{booking_edit_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #f0ad4e;border-color: #eea236;text-decoration:none;'>Editar Reserva</a>"
						},
						{
							:name => 'CANCEL',
							:content => "<a class='btn btn-danger' href='#{booking_cancel_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #d9534f;border-color: #d43f3a;text-decoration:none;'>Cancelar Reserva</a>"
						}
					]
				},
				{
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'RMESSAGE',
							:content => 'Estimado,'
						},
						{
							:name => 'NAME',
							:content => ''
						},
						{
							:name => 'MESSAGE',
							:content => 'Fue agendado un servicio con usted.'
						}
					]
				}
			],
			:tags => ['booking', 'new_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'AgendaPro.png',
					:content => Base64.encode64(File.read('app/assets/images/logos/logo_mail.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_img = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
		else
			company_img = {
				:type => 'image/png',
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
			}
		end
		message[:images] << (company_img)

		# => Metadata
		async = false
		send_at = DateTime.now

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end

	def update_booking (book_info)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		# => Template
		template_name = 'Booking'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Se Actualizo tu Reserva en ' + book_info.service_provider.company.name,
			:to => [
				{
					:email => book_info.email,
					:name => book_info.last_name + ', ' + book_info.first_name,
					:type => 'to'
				},
				{
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => "contacto@agendapro.cl" },
			:global_merge_vars => [
				{
					:name => 'UNSUBSCRIBE',
					:content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.email))}'>aquí</a>."
				},
				{
					:name => 'LNAME',
					:content => book_info.last_name
				},
				{
					:name => 'FNAME',
					:content => book_info.first_name
				},
				{
					:name => 'LOCALNAME',
					:content => book_info.location.name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'SERVICEPRICE',
					:content => if book_info.service.show_price && book_info.service.price && book_info.service.price > 0 then '$' + book_info.service.price.to_s else 'Consultar en Local' end
				},
				{
					:name => 'SERVICEDURATION',
					:content => book_info.service.duration
				},
				{
					:name => 'EMAIL',
					:content => book_info.email
				},
				{
					:name => 'PHONE',
					:content => book_info.phone
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'BEND',
					:content => l(book_info.end)
				},
				{
					:name => 'SIGNATURE',
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br>') end
				}
			],
			:merge_vars => [
				{
					:rcpt => book_info.email,
					:vars => [
						{
							:name => 'RMESSAGE',
							:content => 'Gracias'
						},
						{
							:name => 'NAME',
							:content => book_info.first_name
						},
						{
							:name => 'MESSAGE',
							:content => 'Su cita fue actualizada correctamente'
						},
						{
							:name => 'EDIT',
							:content => "<a class='btn btn-warning' href='#{booking_edit_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #f0ad4e;border-color: #eea236;text-decoration:none;'>Editar Reserva</a>"
						},
						{
							:name => 'CANCEL',
							:content => "<a class='btn btn-danger' href='#{booking_cancel_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #d9534f;border-color: #d43f3a;text-decoration:none;'>Cancelar Reserva</a>"
						}
					]
				},
				{
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'RMESSAGE',
							:content => 'Estimado,'
						},
						{
							:name => 'NAME',
							:content => ''
						},
						{
							:name => 'MESSAGE',
							:content => 'Fue reagendado un servicio con usted, a continuacion se presentan los detalles'
						}
					]
				}
			],
			:tags => ['booking', 'edit_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'AgendaPro.png',
					:content => Base64.encode64(File.read('app/assets/images/logos/logo_mail.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_img = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
		else
			company_img = {
				:type => 'image/png',
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
			}
		end
		message[:images] << (company_img)

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
			:subject => 'Reserva Confirmada',
			:to => [
				{
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => "contacto@agendapro.cl" },
			:global_merge_vars => [
				{
					:name => 'UNSUBSCRIBE',
					:content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.email))}'>aquí</a>."
				},
				{
					:name => 'LNAME',
					:content => book_info.last_name
				},
				{
					:name => 'FNAME',
					:content => book_info.first_name
				},
				{
					:name => 'LOCALNAME',
					:content => book_info.location.name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'SERVICEPRICE',
					:content => if book_info.service.show_price && book_info.service.price && book_info.service.price > 0 then '$' + book_info.service.price.to_s else 'Consultar en Local' end
				},
				{
					:name => 'SERVICEDURATION',
					:content => book_info.service.duration
				},
				{
					:name => 'EMAIL',
					:content => book_info.email
				},
				{
					:name => 'PHONE',
					:content => book_info.phone
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'BEND',
					:content => l(book_info.end)
				}
			],
			:merge_vars => [
				{
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'RMESSAGE',
							:content => 'Estimado,'
						},
						{
							:name => 'NAME',
							:content => ''
						},
						{
							:name => 'MESSAGE',
							:content => 'EL cliente ha confirmado el servicio'
						}
					]
				}
			],
			:tags => ['booking', 'edit_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'AgendaPro.png',
					:content => Base64.encode64(File.read('app/assets/images/logos/logo_mail.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_img = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
		else
			company_img = {
				:type => 'image/png',
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
			}
		end
		message[:images] << (company_img)

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
			:from_name => 'AgendaPro',
			:to => [
				{
					:email => book_info.email,
					:name => book_info.last_name + ', ' + book_info.first_name,
					:type => 'to'
				},
				{
					:email => book_info.service_provider.notification_email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => "contacto@agendapro.cl" },
			:subject => 'Reserva Cancelada en ' + book_info.service_provider.company.name,
			:global_merge_vars => [
				{
					:name => 'UNSUBSCRIBE',
					:content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.email))}'>aquí</a>."
				},
				{
					:name => 'FNAME',
					:content => book_info.first_name
				},
				{
					:name => 'LOCALNAME',
					:content => book_info.location.name
				},
				{
					:name => 'SERVICENAME',
					:content => book_info.service.name
				},
				{
					:name => 'SERVICEPRICE',
					:content => if book_info.service.show_price && book_info.service.price && book_info.service.price > 0 then '$' + book_info.service.price.to_s else 'Consultar en Local' end
				},
				{
					:name => 'SERVICEDURATION',
					:content => book_info.service.duration
				},
				{
					:name => 'EMAIL',
					:content => book_info.email
				},
				{
					:name => 'PHONE',
					:content => book_info.phone
				},
				{
					:name => 'BSTART',
					:content => l(book_info.start)
				},
				{
					:name => 'BEND',
					:content => l(book_info.end)
				},
				{
					:name => 'SIGNATURE',
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br>') end
				}
			],
			:merge_vars => [
				{
					:rcpt => book_info.email,
					:vars => [
						{
							:name => 'RMESSAGE',
							:content => 'Estimado'
						},
						{
							:name => 'NAME',
							:content => book_info.first_name
						},
						{
							:name => 'MESSAGE',
							:content => 'Fue cancelada su cita'
						}
					]
				},
				{
					:rcpt => book_info.service_provider.notification_email,
					:vars => [
						{
							:name => 'RMESSAGE',
							:content => 'Estimado,'
						},
						{
							:name => 'NAME',
							:content => ''
						},
						{
							:name => 'MESSAGE',
							:content => 'Fue cancelado un servicio con usted, a continuacion se presentan los detalles'
						}
					]
				}
			],
			:tags => ['booking', 'cancel_booking'],
			:images => [
				{
					:type => 'image/png',
					:name => 'AgendaPro.png',
					:content => Base64.encode64(File.read('app/assets/images/logos/logo_mail.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_img = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
		else
			company_img = {
				:type => 'image/png',
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
			}
		end
		message[:images] << (company_img)

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
			:from_name => 'AgendaPro',
			:subject => 'Recuerda tu Reserva en ' + book_info.service_provider.company.name,
			:to => [
				{
				  :email => book_info.email,
				  :name => book_info.last_name + ', ' + book_info.first_name,
				  :type => 'to'
				},
				{
				  :email => book_info.service_provider.notification_email,
				  :type => 'to'
				}
			],
			:headers => { 'Reply-To' => "contacto@agendapro.cl" },
			:global_merge_vars => [
				{
				  :name => 'UNSUBSCRIBE',
				  :content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(book_info.email))}'>aquí</a>."
				},
				{
				  :name => 'LNAME',
				  :content => book_info.last_name
				},
				{
				  :name => 'FNAME',
				  :content => book_info.first_name
				},
				{
				  :name => 'LOCALNAME',
				  :content => book_info.location.name
				},
				{
				  :name => 'SERVICENAME',
				  :content => book_info.service.name
				},
				{
				  :name => 'SERVICEPRICE',
				  :content => if book_info.service.show_price && book_info.service.price && book_info.service.price > 0 then '$' + book_info.service.price.to_s else 'Consultar en Local' end
				},
				{
				  :name => 'SERVICEDURATION',
				  :content => book_info.service.duration
				},
				{
				  :name => 'EMAIL',
				  :content => book_info.email
				},
				{
				  :name => 'PHONE',
				  :content => book_info.phone
				},
				{
				  :name => 'BSTART',
				  :content => l(book_info.start)
				},
				{
				  :name => 'BEND',
				  :content => l(book_info.end)
				},
				{
					:name => 'SIGNATURE',
					:content => if !book_info.location.company.company_setting.signature.blank? then book_info.location.company.company_setting.signature.gsub('\r\n', '<br>') end
				}
			],
			:merge_vars => [
				{
				  :rcpt => book_info.email,
				  :vars => [
					{
					  :name => 'RMESSAGE',
					  :content => 'Gracias'
					},
					{
					  :name => 'NAME',
					  :content => book_info.first_name
					},
					{
					  :name => 'MESSAGE',
					  :content => 'Recuerda tu Reserva para mañana.'
					},
					{
						:name => 'EDIT',
						:content => "<a class='btn btn-warning' href='#{booking_edit_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #f0ad4e;border-color: #eea236;text-decoration:none;'>Editar Reserva</a>"
					},
					{
						:name => 'CANCEL',
						:content => "<a class='btn btn-danger' href='#{booking_cancel_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: #d9534f;border-color: #d43f3a;text-decoration:none;'>Cancelar Reserva</a>"
					},
					{
						:name => 'CONFIRM',
						:content => "<a class='btn btn-agendapro-claro btn-lg' href='#{confirm_booking_url(:confirmation_code => book_info.confirmation_code)}' style='display: inline-block;padding: 10px 16px;margin-bottom: 0;font-size: 18px;font-weight: normal;line-height: 1.33;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 6px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: rgba(61,154,150,1);border-color: rgba(55, 133, 129, 1);text-decoration:none;'>Confirmar Reserva</a>"
					}
				  ]
				},
				{
				  :rcpt => book_info.service_provider.notification_email,
				  :vars => [
					{
					  :name => 'RMESSAGE',
					  :content => 'Estimado,'
					},
					{
					  :name => 'NAME',
					  :content => ''
					},
					{
					  :name => 'MESSAGE',
					  :content => 'Recuerda que mañana tienen una hora agendada contigo.'  
					}
				  ]
				}
			],
			:tags => ['booking', 'remind_booking'],
			:images => [
				{
				  :type => 'image/png',
				  :name => 'AgendaPro.png',
				  :content => Base64.encode64(File.read('app/assets/images/logos/logo_mail.png'))
				}
			]
		}

		if !book_info.notes.blank?
			message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
		end

		# => Logo empresa
		if book_info.location.company.logo_url
			company_img = {
				:type => 'image/' +  File.extname(book_info.location.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + book_info.location.company.logo_url.to_s))
			}
		else
			company_img = {
				:type => 'image/png',
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
			}
		end
		message[:images] << (company_img)

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