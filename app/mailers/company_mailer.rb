class CompanyFromEmailMailer < ActionMailer::Base
	require 'mandrill'
	require 'base64'

	def invoice_email(company_id)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		current_date = DateTime.now
		day_number = Time.now.day
	    month_days = Time.now.days_in_month
	    company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(custom: false).where('locations >= ?', company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: company.country.id).price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price
		company = Company.find(company_id)
		unless company.users.where(role_id: Role.find_by_name('Administrador General')).count > 0
			return
		end
		admin = company.users.where(role_id: Role.find_by_name('Administrador General')).first

		sales_tax = NumericParameter.find_by_name("sales_tax").value
		current_amount = ((company.due_amount + (month_days - day_number + 1)*price/month_days)).round(0)
		plan_amount = price
		debt_amount = current_amount - price


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
					:content => (controller.l current_date, :format => '%B').capitalize
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
					:name => 'CURRENT_AMOUNT',
					:content => number_to_currency(current_amount * (1 + sales_tax), {unit: '$', separator: ',', delimiter: '.', precision: 0})
				},
				{
					:name => 'PLAN_AMOUNT',
					:content => number_to_currency(plan_amount * (1 + sales_tax), {unit: '$', separator: ',', delimiter: '.', precision: 0})
				},
				{
					:name => 'DEBT_AMOUNT',
					:content => number_to_currency(debt_amount * (1 + sales_tax), {unit: '$', separator: ',', delimiter: '.', precision: 0})
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
end