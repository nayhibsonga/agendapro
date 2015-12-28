class CompanyMailer < ActionMailer::Base
	require 'mandrill'
	require 'base64'

	#Send a warning notifying tht trial period ends soon (5 days)
	def trial_warning(company_id)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
		company = Company.find(company_id)
	    
		admin = company.users.where(role_id: Role.find_by_name('Administrador General')).first

		sales_tax = company.country.sales_tax

		current_amount = company.calculate_trial_debt
		plan_amount = company.plan.plan_countries.find_by(country_id: company.country.id).price.to_f
		debt_amount = 0


		# => Template
		template_name = 'trial_warning'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => '¡Tu cuenta AgendaPro ya está lista!',
			:to => [
				{
					:email => admin.email,
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
	    
		admin = company.users.where(role_id: Role.find_by_name('Administrador General')).first

		sales_tax = company.country.sales_tax

		current_amount = company.calculate_trial_debt
		plan_amount = company.plan.plan_countries.find_by(country_id: company.country.id).price.to_f
		debt_amount = 0


		# => Template
		template_name = 'trial_end'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => '¡Tu cuenta AgendaPro ya está lista!',
			:to => [
				{
					:email => admin.email,
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
	def invoice_email(company_id)
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
		admin = company.users.where(role_id: Role.find_by_name('Administrador General')).first

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

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => '¡Tu cuenta AgendaPro ya está lista!',
			:to => [
				{
					:email => admin.email,
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

		# => Template
		template_name = 'collection_payment'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Se ha generado un nuevo pago de cobranza.',
			:to => [
				{
					:email => 'iegomez@agendapro.cl, zuru@agendapro.cl',
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
					:content => ActionController::Base.helpers.number_to_currency(current_amount * (1 + sales_tax), locale: company.country.locale.to_sym)
				},
				{
					:name => 'PLAN_AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(plan_amount * (1 + sales_tax), locale: company.country.locale.to_sym)
				},
				{
					:name => 'DEBT_AMOUNT',
					:content => ActionController::Base.helpers.number_to_currency(debt_amount * (1 + sales_tax), locale: company.country.locale.to_sym)
				}
			],
			:tags => ['collection']
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

	end

	def online_receipt_email(company_id)

	end

end	