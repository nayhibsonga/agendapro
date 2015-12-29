class CompanyMailer < ActionMailer::Base
	require 'mandrill'
	require 'base64'
	include ApplicationHelper

	#Send a warning notifying tht trial period ends soon (5 days)
	def trial_warning(company_id)

		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
		company = Company.find(company_id)
	    
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		sales_tax = company.country.sales_tax

		current_amount = company.calculate_trial_debt
		plan_amount = company.plan.plan_countries.find_by(country_id: company.country.id).price.to_f
		debt_amount = 0


		# => Template
		template_name = 'trial_warning'
		template_content = []

		recipients = []
		admins.each do |user|
	      recipients << {
	        :email => user.email,
	        :name => user.full_name,
	        :type => 'to'
	      }
	    end

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Tu período de prueba en AgendaPro está cerca de expirar',
			:to => recipients,
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'CURRENT_YEAR',
					:content => current_date.year
				},
				{
					:name => 'CURRENT_MONTH',
					:content => (l current_date, :format => '%B').capitalize
				},
				{
					:name => 'COMPANY_NAME',
					:content => company.name
				},
				{
					:name => 'ADMIN_NAME',
					:content => admin.full_name
				},
				{
					:name => 'ADMIN_EMAIL',
					:content => admin.email
				},
				{
					:name => 'ACTIVATE_URL',
					:content => select_plan_path
				}
			],
			:tags => ['invoice']
		}

		# => Metadata
		async = false
		send_at = current_date

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end

	#Send end of trial notification
	def trial_end(company_id)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
		company = Company.find(company_id)
	    
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		sales_tax = company.country.sales_tax

		current_amount = company.calculate_trial_debt
		plan_amount = company.plan.plan_countries.find_by(country_id: company.country.id).price.to_f
		debt_amount = 0


		# => Template
		template_name = 'trial_end'
		template_content = []

		recipients = []
		admins.each do |user|
	      recipients << {
	        :email => user.email,
	        :name => user.full_name,
	        :type => 'to'
	      }
	    end

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Fin del período de prueba en AgendaPro',
			:to => recipients,
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'CURRENT_YEAR',
					:content => current_date.year
				},
				{
					:name => 'CURRENT_MONTH',
					:content => (l current_date, :format => '%B').capitalize
				},
				{
					:name => 'COMPANY_NAME',
					:content => company.name
				},
				{
					:name => 'ADMIN_NAME',
					:content => admin.full_name
				},
				{
					:name => 'ADMIN_EMAIL',
					:content => admin.email
				},
				{
					:name => 'CURRENT_AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(current_amount, locale: company.country.locale.to_sym)
				},
				{
					:name => 'PLAN_AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(plan_amount, locale: company.country.locale.to_sym)
				},
				{
					:name => 'DEBT_AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(debt_amount, locale: company.country.locale.to_sym)
				},
				{
					:name => 'ACTIVATE_URL',
					:content => select_plan_path
				}
			],
			:tags => ['invoice']
		}

		# => Metadata
		async = false
		send_at = current_date

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise

	end

	#Send a warning notifying tht trial period ends soon (5 days)
	def trial_recovery(company_id)

		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
		company = Company.find(company_id)
	    
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		sales_tax = company.country.sales_tax

		current_amount = company.calculate_trial_debt
		plan_amount = company.plan.plan_countries.find_by(country_id: company.country.id).price.to_f
		debt_amount = 0


		# => Template
		template_name = 'trial_recovery'
		template_content = []

		recipients = []
		admins.each do |user|
	      recipients << {
	        :email => user.email,
	        :name => user.full_name,
	        :type => 'to'
	      }
	    end

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => '¿Necesitas ayuda con tu cuenta AgendaPro?',
			:to => recipients,
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'CURRENT_YEAR',
					:content => current_date.year
				},
				{
					:name => 'CURRENT_MONTH',
					:content => (l current_date, :format => '%B').capitalize
				},
				{
					:name => 'COMPANY_NAME',
					:content => company.name
				},
				{
					:name => 'ADMIN_NAME',
					:content => admin.full_name
				},
				{
					:name => 'ADMIN_EMAIL',
					:content => admin.email
				},
				{
					:name => 'ACTIVATE_URL',
					:content => select_plan_path
				}
			],
			:tags => ['invoice']
		}

		# => Metadata
		async = false
		send_at = current_date

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end

	#Send invoice_email charging for new month.
	def invoice_email(company_id, reminder_message)
		#return
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
		company = Company.find(company_id)
	    company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where.not(id: Plan.find_by_name("Gratis").id).where(custom: false).where('locations >= ?', company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: company.country.id).price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price
		unless company.users.where(role_id: Role.find_by_name('Administrador General')).count > 0
			return
		end
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		sales_tax = company.country.sales_tax
		#current_amount = ((company.due_amount + (month_days - day_number + 1)*price/month_days)).round(0)
		plan_amount = price * (1 + sales_tax)
		#debt_amount = current_amount - price

		current_amount = plan_amount + company.due_amount
		debt_amount = company.due_amount

		puts "Current: " + current_amount.to_s
		puts "Debt: " + debt_amount.to_s
		puts "Plan: " + plan_amount.to_s


		# => Template
		template_name = 'invoice'
		template_content = []

		recipients = []
		admins.each do |user|
	      recipients << {
	        :email => user.email,
	        :name => user.full_name,
	        :type => 'to'
	      }
	    end

		# => Message

		if reminder_message != ""

			message = {
				:from_email => 'no-reply@agendapro.cl',
				:from_name => 'AgendaPro',
				:subject => 'Recordatorio de cuenta AgendaPro',
				:to => recipients,
				:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
				:global_merge_vars => [
					{
						:name => 'CURRENT_YEAR',
						:content => current_date.year
					},
					{
						:name => 'CURRENT_MONTH',
						:content => (l current_date, :format => '%B').capitalize
					},
					{
						:name => 'COMPANY_NAME',
						:content => company.name
					},
					{
						:name => 'ADMIN_NAME',
						:content => admin.full_name
					},
					{
						:name => 'ADMIN_EMAIL',
						:content => admin.email
					},
					{
						:name => 'CURRENT_AMOUNT',
						:content => ActionController::Base.helpers.number_to_currency(current_amount, locale: company.country.locale.to_sym)
					},
					{
						:name => 'PLAN_AMOUNT',
						:content => ActionController::Base.helpers.number_to_currency(plan_amount, locale: company.country.locale.to_sym)
					},
					{
						:name => 'DEBT_AMOUNT',
						:content => ActionController::Base.helpers.number_to_currency(debt_amount, locale: company.country.locale.to_sym)
					},
					{
						:name => 'IS_REMINDER',
						:content => true
					},
					{
						:name => 'REMINDER_MESSAGE',
						:content => reminder_message
					}
				],
				:tags => ['invoice']
			}

		else

			message = {
				:from_email => 'no-reply@agendapro.cl',
				:from_name => 'AgendaPro',
				:subject => '¡Tu cuenta AgendaPro ya está lista!',
				:to => recipients,
				:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
				:global_merge_vars => [
					{
						:name => 'CURRENT_YEAR',
						:content => current_date.year
					},
					{
						:name => 'CURRENT_MONTH',
						:content => (l current_date, :format => '%B').capitalize
					},
					{
						:name => 'COMPANY_NAME',
						:content => company.name
					},
					{
						:name => 'ADMIN_NAME',
						:content => admin.full_name
					},
					{
						:name => 'ADMIN_EMAIL',
						:content => admin.email
					},
					{
						:name => 'CURRENT_AMOUNT',
						:content => ActionController::Base.helpers.number_to_currency(current_amount, locale: company.country.locale.to_sym)
					},
					{
						:name => 'PLAN_AMOUNT',
						:content => ActionController::Base.helpers.number_to_currency(plan_amount, locale: company.country.locale.to_sym)
					},
					{
						:name => 'DEBT_AMOUNT',
						:content => ActionController::Base.helpers.number_to_currency(debt_amount, locale: company.country.locale.to_sym)
					}
				],
				:tags => ['invoice']
			}

		end

		# => Metadata
		async = false
		send_at = current_date

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end

	#Send mail to Nico (or other) warning about a new billing_wire_transfer
	def new_transfer_email(transfer_id)

		mandrill = Mandrill::API.new Agendapro::Application.config.api_key
		transfer = BillingWireTransfer.find(transfer_id)
		company = transfer.company
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admin.first

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month

		# => Template
		template_name = 'new_transfer'
		template_content = []

		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Nueva transferencia de pago de cuenta',
			:to => [
				{
					:email => 'iegomez@agendapro.cl',
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'CURRENT_YEAR',
					:content => current_date.year
				},
				{
					:name => 'CURRENT_MONTH',
					:content => (l current_date, :format => '%B').capitalize
				},
				{
					:name => 'COMPANY',
					:content => company.name
				},
				{
					:name => 'ADMIN_NAME',
					:content => admin.full_name
				},
				{
					:name => 'EMAIL',
					:content => admin.email
				},
				{
					:name => 'AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(transfer.amount, locale: company.country.locale.to_sym)
				},
				{
					:name => 'RECEIPT_NUMBER',
					:content => transfer.receipt_number
				},
				{
					:name => 'DATE',
					:content => transfer.payment_date.strftime('%d/%m/%Y %R')
				}
			],
			:tags => []
		}

		# => Metadata
		async = false
		send_at = current_date

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise


	end

	def transfer_receipt_email(transfer_id)

		mandrill = Mandrill::API.new Agendapro::Application.config.api_key
		transfer = BillingWireTransfer.find(transfer_id)
		company = transfer.company
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month

		# => Template
		template_name = 'transfer_receipt'
		template_content = []

		recipients = []
		admins.each do |user|
	      recipients << {
	        :email => user.email,
	        :name => user.full_name,
	        :type => 'to'
	      }
	    end

		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Comprobante de pago de cuenta AgendaPro',
			:to => recipients,
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'CURRENT_YEAR',
					:content => current_date.year
				},
				{
					:name => 'CURRENT_MONTH',
					:content => (l current_date, :format => '%B').capitalize
				},
				{
					:name => 'COMPANY',
					:content => company.name
				},
				{
					:name => 'ADMIN_NAME',
					:content => admin.full_name
				},
				{
					:name => 'EMAIL',
					:content => admin.email
				},
				{
					:name => 'AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(transfer.amount, locale: company.country.locale.to_sym)
				},
				{
					:name => 'RECEIPT_NUMBER',
					:content => transfer.receipt_number
				},
				{
					:name => 'DATE',
					:content => transfer.payment_date.strftime('%d/%m/%Y %R')
				}
			],
			:tags => []
		}

		# => Metadata
		async = false
		send_at = current_date

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise


	end

	def online_receipt_email(company_id, punto_pagos_confirmation_id)

		mandrill = Mandrill::API.new Agendapro::Application.config.api_key
		company = Company.find(company_id)
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		punto_pagos_confirmation = PuntoPagosConfirmation.find(punto_pagos_confirmation_id)
		amount = punto_pagos_confirmation.amount

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month

		# => Template
		template_name = 'online_receipt'
		template_content = []

		recipients = []
		admins.each do |user|
	      recipients << {
	        :email => user.email,
	        :name => user.full_name,
	        :type => 'to'
	      }
	    end

		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Comprobante de pago de cuenta AgendaPro',
			:to => recipients,
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'CURRENT_YEAR',
					:content => current_date.year
				},
				{
					:name => 'CURRENT_MONTH',
					:content => (l current_date, :format => '%B').capitalize
				},
				{
					:name => 'COMPANY',
					:content => company.name
				},
				{
					:name => 'ADMIN_NAME',
					:content => admin.full_name
				},
				{
					:name => 'EMAIL',
					:content => admin.email
				},
				{
					:name => 'AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(amount, locale: company.country.locale.to_sym)
				},
				{
					:name => 'PAYMENT_METHOD',
					:content => code_to_payment_method(punto_pagos_confirmation.payment_method)
				},
				{
					:name => 'CARD_NUMBER',
					:content => "********" + punto_pagos_confirmation.card_number
				},
				{
					:name => 'ORDER',
					:content => punto_pagos_confirmation.operation_number
				},
				{
					:name => 'AUTH_CODE',
					:content => punto_pagos_confirmation.authorization_code
				},
				{
					:name => 'DATE',
					:content => punto_pagos_confirmation.created_at.strftime('%d/%m/%Y %R')
				}
			],
			:tags => []
		}

		# => Metadata
		async = false
		send_at = current_date

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise

	end

	def pay_u_online_receipt_email(company_id, pay_u_notification_id)

		mandrill = Mandrill::API.new Agendapro::Application.config.api_key
		company = Company.find(company_id)
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		pay_u_notification = PayUNotification.find(pay_u_notification_id)
		amount = pay_u_notification.value

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month

	    card_number = ""
	    if !pay_u_notification.cc_number.nil?
	    	card_number = "********" + pay_u_notification.cc_number
	    end

		# => Template
		template_name = 'online_receipt'
		template_content = []

		recipients = []
		admins.each do |user|
	      recipients << {
	        :email => user.email,
	        :name => user.full_name,
	        :type => 'to'
	      }
	    end

		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Comprobante de pago de cuenta AgendaPro',
			:to => recipients,
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'CURRENT_YEAR',
					:content => current_date.year
				},
				{
					:name => 'CURRENT_MONTH',
					:content => (l current_date, :format => '%B').capitalize
				},
				{
					:name => 'COMPANY',
					:content => company.name
				},
				{
					:name => 'ADMIN_NAME',
					:content => admin.full_name
				},
				{
					:name => 'EMAIL',
					:content => admin.email
				},
				{
					:name => 'AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(amount, locale: company.country.locale.to_sym)
				},
				{
					:name => 'PAYMENT_METHOD',
					:content => pay_u_notification.payment_method_name
				},
				{
					:name => 'CARD_NUMBER',
					:content => card_number
				},
				{
					:name => 'AUTH_CODE',
					:content => pay_u_notification.authorization_code
				},
				{
					:name => 'DATE',
					:content => pay_u_notification.created_at.strftime('%d/%m/%Y %R')
				}
			],
			:tags => []
		}

		# => Metadata
		async = false
		send_at = current_date

		# => Send mail
		result = mandrill.messages.send_template template_name, template_content, message, async, send_at

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise

	end

end	