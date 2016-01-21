class CompanyMailer < Base::CustomMailer
	include ApplicationHelper

	#Send a warning notifying tht trial period ends soon (5 days)
	def trial_warning(company_id)

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

		is_chile = true
		if company.country.name != "Chile"
			is_chile = false
		end


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
					:content => select_plan_url
				},
				{
					:name => 'CHILE',
					:content => is_chile
				}
			],
			:tags => ['invoice']
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	#Send end of trial notification
	def trial_end(company_id)
		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
		company = Company.find(company_id)

		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		sales_tax = company.country.sales_tax

		current_amount = company.calculate_trial_debt
		plan_amount = company.company_plan_setting.base_price * company.company_plan_setting.locations_multiplier
		debt_amount = company.due_amount

		is_chile = true
		if company.country.name != "Chile"
			is_chile = false
		end


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
					:content => select_plan_url
				},
				{
					:name => 'CHILE',
					:content => is_chile
				}
			],
			:tags => ['invoice']
		}

		# => Send mail
		send_mail(template_name, template_content, message)

	end

	#Send a warning notifying tht trial period ends soon (5 days)
	def trial_recovery(company_id)

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
		company = Company.find(company_id)

		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		sales_tax = company.country.sales_tax

		current_amount = company.calculate_trial_debt
		plan_amount = company.company_plan_setting.base_price * company.company_plan_setting.locations_multiplier
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
					:content => select_plan_url
				}
			],
			:tags => ['invoice']
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	#Send invoice_email charging for new month.
	def invoice_email(company_id, reminder_message)
		
		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
		company = Company.find(company_id)

	    #company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where.not(id: Plan.find_by_name("Gratis").id).where(custom: false).where('locations >= ?', company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: company.country.id).price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price
		unless company.users.where(role_id: Role.find_by_name('Administrador General')).count > 0
			return
		end

		price = company.company_plan_setting.base_price * company.company_plan_setting.locations_multiplier

		is_chile = true
		if company.country.name != "Chile"
			is_chile = false
		end

		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

		sales_tax = company.country.sales_tax
		#current_amount = ((company.due_amount + (month_days - day_number + 1)*price/month_days)).round(0)
		plan_amount = price * (1 + sales_tax)
		#debt_amount = current_amount - price

		if company.plan_id == Plan.find_by_name("Gratis").id

			downgradeLog = DowngradeLog.where(company_id: company.id).order('created_at desc').first

			if !downgradeLog.nil?
				prev_plan = Plan.find(downgradeLog.plan_id)
				price = prev_plan.plan_countries.find_by(country_id: company.country.id).price
				plan_amount = ((month_days.to_f - day_number + 1) / month_days.to_f) * price * (1 + sales_tax)
			end

		end

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
					},
					{
						:name => 'ACTIVATE_URL',
						:content => select_plan_url
					},
					{
						:name => 'CHILE',
						:content => is_chile
					}
				],
				:tags => ['invoice']
			}

		else

			message = {
				:from_email => 'no-reply@agendapro.cl',
				:from_name => 'AgendaPro',
				:subject => '¡Ya puedes pagar tu cuenta AgendaPro!',
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
						:content => select_plan_url
					},
					{
						:name => 'CHILE',
						:content => is_chile
					}
				],
				:tags => ['invoice']
			}

		end

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	#Send mail to Nico (or other) warning about a new billing_wire_transfer
	def new_transfer_email(transfer_id)
		transfer = BillingWireTransfer.find(transfer_id)
		company = transfer.company
		admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
		admin = admins.first

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
					:email => 'cuentas@agendapro.cl',
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
					:name => 'DATE',
					:content => transfer.payment_date.strftime('%d/%m/%Y %R')
				}
			],
			:tags => []
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	def transfer_receipt_email(transfer_id)
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
					:name => 'DATE',
					:content => transfer.payment_date.strftime('%d/%m/%Y %R')
				}
			],
			:tags => []
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	def online_receipt_email(company_id, punto_pagos_confirmation_id)
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

		is_chile = true
		if company.country.name != "Chile"
			is_chile = false
		end

		recipients = []
		admins.each do |user|
	      recipients << {
	        :email => user.email,
	        :name => user.full_name,
	        :type => 'to'
	      }
	    end

	    recipients << {
	    	:email => 'cuentas@agendapro.cl',
	    	:name => 'Cuentas AgendaPro',
	    	:type => 'to'
	    }

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
				},
				{
					:name => 'CHILE',
					:content => is_chile
				}
			],
			:tags => []
		}

		# => Send mail
		send_mail(template_name, template_content, message)
	end

	def pay_u_online_receipt_email(company_id, pay_u_notification_id)
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

	    is_chile = true
		if company.country.name != "Chile"
			is_chile = false
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

	    recipients << {
	    	:email => 'cuentas@agendapro.cl',
	    	:name => 'Cuentas AgendaPro',
	    	:type => 'to'
	    }

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
				},
				{
					:name => 'CHILE',
					:content => false
				}
			],
			:tags => []
		}
		send_mail(template_name, template_content, message)
	end

end
