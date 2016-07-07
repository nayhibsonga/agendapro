class Company < ActiveRecord::Base

	belongs_to :plan
	belongs_to :payment_status
	belongs_to :country
	belongs_to :default_plan, class_name: 'Plan', foreign_key: "default_plan_id"

	has_many :company_economic_sectors
	has_many :economic_sectors, :through => :company_economic_sectors

	has_many :company_countries
	has_many :countries, :through => :company_countries

	has_many :cashiers, dependent: :destroy
	has_many :email_contents, dependent: :destroy, class_name: 'Email::Content'

	has_many :custom_attributes, foreign_key: 'company_id', class_name: 'Attribute'
	has_many :attribute_groups

	has_many :chart_fields
	has_many :chart_groups
	has_many :charts

	has_many :custom_filters, dependent: :destroy

	has_many :super_admin_logs
	has_many :company_cron_logs

	accepts_nested_attributes_for :company_countries, :reject_if => :reject_company_country, :allow_destroy => true

	def reject_company_country(attributes)
	  exists = attributes['id'].present?
	  empty = attributes.slice(:web_address).blank?
	  attributes.merge!({:_destroy => 1}) if exists and empty # destroy empty tour
	  return (!exists and empty) # reject empty attributes
	end

	has_many :users, dependent: :nullify
	has_many :plan_logs, dependent: :destroy
	has_many :billing_logs, dependent: :destroy
	has_many :billing_records, dependent: :destroy
	has_many :services, dependent: :destroy
	has_many :service_providers, dependent: :destroy
	has_many :locations, dependent: :destroy
	has_many :service_categories, dependent: :destroy
	has_many :clients, dependent: :destroy
	has_one :company_setting, dependent: :destroy
	has_one :settings, dependent: :destroy, class_name: 'CompanySetting'
	has_one :billing_info, dependent: :destroy
	belongs_to :bank
	has_many :company_from_email, dependent: :destroy
	has_many :staff_codes, dependent: :destroy
	has_many :deals, dependent: :destroy
	has_many :company_payment_methods, dependent: :destroy
	has_many :payment_accounts, dependent: :destroy
	has_many :products, dependent: :destroy
	has_many :product_brands, dependent: :destroy
	has_many :product_displays, dependent: :destroy
	has_many :product_categories, dependent: :destroy
	has_many :billing_wire_transfers
	has_many :downgrade_logs
	has_many :employee_codes, dependent: :destroy

	has_one :company_plan_setting

	has_many :company_files

	has_many :client_files, :through => :clients

	has_many :sendings, class_name: 'Email::Sending', as: :sendable

	scope :collectables, -> { where(active: true).where('created_at <= ?', DateTime.now - 2.months).where.not(plan_id: Plan.where(name: ["Gratis", "Trial"]).pluck(:id)).where.not(payment_status_id: PaymentStatus.where(name: ["Inactivo", "Bloqueado", "Admin", "Convenio PAC"]).pluck(:id)) }
	scope :former_trials, -> { where(active: true).where('created_at > ?', DateTime.now - 2.months).where.not(plan_id: Plan.where(name: ["Gratis", "Trial"]).pluck(:id)).where.not(payment_status_id: PaymentStatus.where(name: ["Inactivo", "Bloqueado", "Admin", "Convenio PAC"]).pluck(:id)) }
	scope :regular_blocked, -> { where(active: true).where('created_at <= ?', DateTime.now - 2.months).where.not(plan_id: Plan.where(name: ["Gratis", "Trial"]).pluck(:id)).where(payment_status_id: PaymentStatus.find_by_name("Bloqueado").id) }

	validates :name, :web_address, :plan, :payment_status, :country, :presence => true

	validates_uniqueness_of :web_address, scope: :country_id

	mount_uploader :logo, LogoUploader

	accepts_nested_attributes_for :company_setting

	validate :plan_settings

	after_update :update_online_payment, :update_stats

	after_create :create_cashier, :create_plan_setting, :create_attribute_group,

	WORKER = 'CompanyEmailWorker'

	#Log changes made by a Super Admin or Ventas user
	# def log_changes
	# 	if !self.users.pluck(:id).include? current_user.id
	# 		if self.previous_changes.count > 0

	# 		end
	# 	end
	# end

	def create_attribute_group
		if AttributeGroup.where(name: "Otros", company_id: self.id).count < 1
			AttributeGroup.create(name: "Otros", company_id: self.id, order: 1)
		end
	end

	def is_plan_capable(name)

		if self.plan.name == "Trial" || self.payment_status.name == "Trial"
			return true
		end

		if self.plan.custom
			return false
		end

		if name == "Normal"
			if self.plan.name == "Normal" || self.plan.name == "Premium" || self.plan.name == "Pro"
				return true
			else
				return false
			end
		elsif name == "Premium"
			if self.plan.name == "Premium" || self.plan.name == "Pro"
				return true
			else
				return false
			end
		elsif name == "Pro"
			if self.plan.name == "Pro"
				return true
			else
				return false
			end
		else
			return false
		end

	end

	def create_plan_setting
		CompanyPlanSetting.create(company_id: self.id, base_price: self.plan.plan_countries.find_by(country_id: self.country.id).price, locations_multiplier: NumericParameter.find_by_name("locations_multiplier").value)
		#Set default plan
		self.update(:default_plan_id => Plan.where(custom: false, name: "Normal").first.id)
	end

	def computed_multiplier
		return_value = (1 + (self.locations.where(active:true).count - 1) * self.company_plan_setting.locations_multiplier)
		if return_value < 1
			return_value = 1
		end
		return return_value
	end

	def get_storage_occupation

		used_storage = 0
		used_storage += self.company_files.sum(:size)
		used_storage += self.client_files.sum(:size)

	end

	def create_cashier
		cashier = Cashier.create(company_id: self.id, name: "Cajero 1", code: "12345678", active: true)
	end

	def plan_settings
		#If it's custom, keep locations/service_providers revisions
		if self.plan.custom || self.plan.name == "Personal"
			if self.locations.where(active: true).count > self.plan.locations || self.service_providers.where(active: true, location_id: self.locations.where(active: true).pluck(:id)).count > self.plan.service_providers
				errors.add(:base, "El plan no pudo ser cambiado. Tienes más locales y/o prestadores activos que lo que permite el plan.")
			end
		else
			#Generate debt change when locations are increased/decreased.
		end
	end

	def secret_code
		crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
		encrypted_data = crypt.encrypt_and_sign(self.id.to_s)
		return encrypted_data
	end

	def encode_company_token
		return (self.id * 12345678).to_s(30)
	end

	def self.api_decode_and_find(token)
		id = token.to_i(30) / 12345678
		return Company.find_by_id(id)
	end

	def self.substract_month
		month_days = Time.now.days_in_month
		where(payment_status_id: PaymentStatus.find_by_name("Activo").id).each do |company|
			company.months_active_left -= 1.0
			payment_status = "Activo"
			if company.months_active_left <= 0
				payment_status = "Emitido"
				company.due_date = Time.now
				company.payment_status_id = PaymentStatus.find_by_name("Emitido").id
			end
			if company.save
				CompanyCronLog.create(company_id: company.id, action_ref: 1, details: "OK substract_month")
				if company.payment_status_id == PaymentStatus.find_by_name("Emitido").id && company.country_id == 1
					company.sendings.build(method: 'invoice').save
				end
			else
				errors = ""
				company.errors.full_messages.each do |error|
					errors += error
				end
				CompanyCronLog.create(company_id: company.id, action_ref: 1, details: "ERROR substract_month "+errors)
			end
		end
	end

	def self.payment_expiry
		where(payment_status_id: PaymentStatus.find_by_name("Emitido").id).where('due_date < ?', 19.days.ago).each do |company|
			company.payment_status_id = PaymentStatus.find_by_name("Vencido").id
			if company.save
				CompanyCronLog.create(company_id: company.id, action_ref: 2, details: "OK payment_expiry")
				if company.country_id == 1
					company.sendings.build(method: 'invoice').save
				end
			else
				errors = ""
				company.errors.full_messages.each do |error|
					errors += error
				end
				CompanyCronLog.create(company_id: company.id, action_ref: 2, details: "ERROR payment_expiry "+errors)
			end
		end
	end

	def self.payment_shut
		where(payment_status_id: PaymentStatus.find_by_name("Vencido").id).where('due_date < ?', (1.months + 5.days).ago).each do |company|
			company.payment_status_id = PaymentStatus.find_by_name("Bloqueado").id
			if company.save
				CompanyCronLog.create(company_id: company.id, action_ref: 3, details: "OK payment_shut")
			else
				errors = ""
				company.errors.full_messages.each do |error|
					errors += error
				end
				CompanyCronLog.create(company_id: company.id, action_ref: 3, details: "ERROR payment_shut "+errors)
			end
		end
	end

	def self.payment_inactive
		where(payment_status_id: PaymentStatus.find_by_name("Bloqueado").id).where('due_date < ?', (1.months+15.days).ago).each do |company|
			company.payment_status_id = PaymentStatus.find_by_name("Inactivo").id
			# company.due_amount = 0.0
			company.active = false
			if company.save
				CompanyCronLog.create(company_id: company.id, action_ref: 4, details: "OK payment_inactive")
			else
				errors = ""
				company.errors.full_messages.each do |error|
					errors += error
				end
				CompanyCronLog.create(company_id: company.id, action_ref: 4, details: "ERROR payment_inactive "+errors)
			end
		end
	end


	#Change
	# def self.end_trial
	# 	month_days = Time.now.days_in_month
	# 	where(payment_status_id: PaymentStatus.find_by_name("Trial").id).where.not(plan_id: Plan.find_by_name("Gratis").id).where('created_at <= ?', 1.months.ago).each do |company|
	# 		plan_id = Plan.where.not(id: Plan.find_by_name("Gratis").id).where(custom: false).where('locations >= ?', company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.id
	# 		company.plan_id = plan_id
	# 		company.due_date = Time.now
	# 		company.payment_status_id = PaymentStatus.find_by_name("Emitido").id
	# 		if company.save
	# 			CompanyCronLog.create(company_id: company.id, action_ref: 5, details: "OK end_trial")
	# 			if company.country_id == 1
	# 				CompanyMailer.invoice_email(company.id)
	# 			end
	# 		else
	# 			errors = ""
	# 			company.errors.full_messages.each do |error|
	# 				errors += error
	# 			end
	# 			CompanyCronLog.create(company_id: company.id, action_ref: 5, details: "ERROR end_trial "+errors)
	# 		end
	# 	end
	# end

	def self.add_due_amount
		month_days = Time.now.days_in_month
		where(payment_status_id: PaymentStatus.where(name: ["Emitido", "Vencido"]).pluck(:id)).where('due_date IS NOT NULL').each do |company|
			company.due_amount += company.plan.plan_countries.find_by(country_id: company.country.id).price/month_days
			if company.save
				CompanyCronLog.create(company_id: company.id, action_ref: 6, details: "OK add_due_amount")
			else
				errors = ""
				company.errors.full_messages.each do |error|
					errors += error
				end
				CompanyCronLog.create(company_id: company.id, action_ref: 6, details: "ERROR add_due_amount "+errors)
			end
		end
	end

	def self.invoice_email
		where(payment_status_id: PaymentStatus.where(name: ["Emitido", "Vencido"]).pluck(:id), due_date: [10.days.ago, 15.days.ago, 20.days.ago], country_id: 1).each do |company|
			company.sendings.build(method: 'invoice').save
		end
	end

	def update_online_payment

		if !self.company_setting.online_payment_capable
			self.company_setting.allows_online_payment = false
		end

		if !self.company_setting.allows_online_payment
			self.services.each do |service|
				service.online_payable = false
				service.save
			end
		end

		#Si cambia los datos de la cuenta, hay que actualizar el payment_account
		if !self.payment_accounts.nil?
			self.payment_accounts.each do |pa|
				pa.number = self.company_setting.account_number
				pa.rut = self.company_setting.company_rut
				pa.name = self.company_setting.account_name
				pa.account_type = self.company_setting.account_type
				pa.save
			end
		end
	end

	def update_stats
		if changed_attributes['web_address'] || changed_attributes['country_id']
			cc = CompanyCountry.find_by(company_id: self.id, country_id: self.country_id)
			cc.web_address = self.web_address
			cc.save
		end

		company = self
		stats = StatsCompany.find_or_initialize_by(company_id: company.id)
  		stats.company_name = company.name
  		stats.company_start = company.created_at
  		stats.company_payment_status_id = company.payment_status_id
  		stats.company_sales_user_id = company.sales_user_id
  		stats.web_bookings = 0.0
  		if Booking.where(location_id: Location.where(company_id: company.id)).count > 0
  			stats.last_booking = Booking.where(location_id: Location.where(company_id: company.id)).last.created_at
  			stats.web_bookings = Booking.where(location_id: Location.where(company_id: company.id), web_origin: true).count.to_f / Booking.where(location_id: Location.where(company_id: company.id)).count.to_f
  		end
  		stats.week_bookings = Booking.where(location_id: Location.where(company_id: company.id), created_at: 7.days.ago..Time.now).count
  		stats.past_week_bookings = Booking.where(location_id: Location.where(company_id: company.id), created_at: 14.days.ago..7.days.ago).count

  		last_payment_arr = company.last_payment_detail
  		stats.last_payment = last_payment_arr[0]
  		stats.last_payment_method = last_payment_arr[2]

		#bl = BillingLog.where(:company_id => company.id).where(:trx_id => PuntoPagosConfirmation.where(:response => "00").pluck(:trx_id)).order('created_at desc').first
		#rec = BillingRecord.where(:company_id => company.id).order('date desc').first
		#if !bl.nil? && !rec.nil?
		#	if bl.created_at <= rec.date
		# 		stats.last_payment = rec.date
		# 		stats.last_payment_method = "Manual - " + (rec.transaction_type ? rec.transaction_type.name : "No definido")
		# 	else
		# 		stats.last_payment = bl.created_at
		# 		stats.last_payment_method = "Automático"
		# 	end
		# elsif bl.nil? && !rec.nil?
		# 	stats.last_payment = rec.date
		# 	stats.last_payment_method = "Manual - " + (rec.transaction_type ? rec.transaction_type.name : "No definido")
		# elsif !bl.nil? && rec.nil?
		# 	stats.last_payment = bl.created_at
		# 	stats.last_payment_method = "Automático"
		# end

		stats.save
	end

	########################
	## Collection methods ##
	########################

	#Check if account has been used in the past week for status change purposes.
	def account_used

		if Booking.where(location_id: Location.where(company_id: self.id).pluck(:id)).where('created_at > ?', DateTime.now - 1.weeks).count > 0
			return true
		end

		return false

	end

	def account_used_all

		if self.account_used
			return true
		end

		if Payment.where(company_id: self.id).where('created_at > ?', DateTime.now - 1.weeks).count > 0
			return true
		end

		if Product.where(company_id: self.id).where('updated_at > ?', DateTime.now - 1.weeks).count > 0
			return true
		end

		if Email::Content.where(company_id: self.id).where('updated_at > ?', DateTime.now - 1.weeks).count > 0
			return true
		end

		return false
	end

	#Calculate debt amount for former trial companies.
	#Get days count till end of month, divide by month length and multiply by company's plan price.
	def calculate_trial_debt

		sales_tax = self.country.sales_tax
		day_number = Time.now.day
    	month_number = Time.now.month
    	month_days = Time.now.days_in_month

		debt_proportion = (month_days - day_number + 1).to_f/month_days.to_f

		#debt = self.plan.plan_countries.find_by(country_id: self.country.id).price.to_f * debt_proportion * ( 1 + sales_tax)
		debt = self.company_plan_setting.base_price * self.computed_multiplier * debt_proportion * (1 + sales_tax)

		return debt

	end

	#Legacy
	def calculate_plan_change(new_plan_id)

		current_date = Date.today
		month_end = current_date.end_of_month
		debt_proportion = (month_end.day.to_f - current_date.day.to_f)/month_end.day.to_f

		new_plan = Plan.find(new_plan_id)
		new_price = new_plan.plan_countries.find_by(country_id: self.country.id).price.to_f

		old_price = self.plan.plan_countries.find_by(country_id: self.country.id).price.to_f

		#If it's negative, it means that we owe the company for changing to a cheaper plan.
		#It's like a deposit (un abono)

		price_diff = new_price - old_price

		new_debt = price_diff * debt_proportion

		return new_debt

	end

	# Warn trial ending 5 days before it ends
	def self.warn_trial

		where(active: true, payment_status_id: PaymentStatus.find_by_name("Trial").id).where('created_at BETWEEN ? AND ?', (1.months.ago + 5.days).beginning_of_day, (1.months.ago + 5.days).end_of_day).each do |company|

			if company.account_used
				company.sendings.build(method: 'warning_trial').save
			else
				company.sendings.build(method: 'recovery_trial').save
			end

		end

	end

	def self.end_trial

		day_number = Time.now.day
    	month_number = Time.now.month
    	month_days = Time.now.days_in_month

		where(active: true, payment_status_id: PaymentStatus.find_by_name("Trial").id).where.not(plan_id: Plan.find_by_name("Gratis").id).where('created_at <= ?', 1.months.ago).each do |company|

			#New plan should be the default one
			plan = company.default_plan

			#If default wasn't changed, then set plan by locations and providers number
			# if plan.name == "Normal" || plan.name == "Personal"
			# 	if company.locations.where(active: true).count > 1 || company.service_providers.where(location_id: company.				locations.where(active: true).pluck(:id), active:true).count > 1
			# 		plan = Plan.where(name: "Normal", custom: false).first
			# 	else
			# 		plan = Plan.where(name: "Personal", custom: false).first
			# 	end
 		# 	end

			sales_tax = company.country.sales_tax

			company.plan_id = plan.id
			company.company_plan_setting.base_price = plan.plan_countries.find_by_country_id(company.country.id).price
			company.company_setting.mails_base_capacity = plan.monthly_mails

			company.due_date = Time.now
			#company.due_amount = - 1 * ((day_number - 1).to_f / month_days.to_f) * company.plan.plan_countries.find_by(country_id: company.country.id).price * (1 + sales_tax)
			company.due_amount = (- 1 * ((day_number - 1).to_f / month_days.to_f) * company.company_plan_setting.base_price * company.computed_multiplier * (1 + sales_tax)).round(0)


			company.months_active_left = 0
			company.payment_status_id = PaymentStatus.find_by_name("Emitido").id

			if company.save

				company.company_plan_setting.save
				company.company_setting.save

				CompanyCronLog.create(company_id: company.id, action_ref: 5, details: "OK end_trial")

				#Check if account was used.
				if company.account_used
					company.sendings.build(method: 'end_trial').save
				else
					company.sendings.build(method: 'recovery_trial').save
				end

				#if company.country_id == 1
				#	CompanyMailer.invoice_email(company.id)
				#end
			else
				errors = ""
				company.errors.full_messages.each do |error|
					errors += error
				end
				CompanyCronLog.create(company_id: company.id, action_ref: 5, details: "ERROR end_trial "+errors)
			end

		end
	end

	def self.former_trials_process

		status_activo = PaymentStatus.find_by_name("Activo")
		#First, remind after 5 days
		former_trials.where('created_at BETWEEN ? AND ?', (DateTime.now - 1.months - 5.days).beginning_of_day, (DateTime.now - 1.months - 5.days).end_of_day).each do |company|
			if !company.account_used_all
				company.sendings.build(method: 'recovery_trial').save
			else
				if company.payment_status_id != status_activo.id
					company.sendings.build(method: 'message_invoice').save
				end
			end
		end

		#Then, insist after 15 days
		#Send second reminder (insistence)
		former_trials.where('created_at BETWEEN ? AND ?', (DateTime.now - 1.months - 15.days).beginning_of_day, (DateTime.now - 1.months - 15.days).end_of_day).each do |company|
			if !company.account_used_all
				company.sendings.build(method: 'recovery_trial').save
			else
				if company.payment_status_id != status_activo.id
					company.sendings.build(method: 'reminder_message_invoice').save
				end
			end
		end

		#Send ultimatum saying they will be downgraded on failure to pay
		former_trials.where('created_at BETWEEN ? AND ?', (DateTime.now - 1.months - 25.days).beginning_of_day, (DateTime.now - 1.months - 25.days).end_of_day).each do |company|
			if !company.account_used_all
				company.sendings.build(method: 'recovery_trial').save
			else
				if company.payment_status_id != status_activo.id
					company.sendings.build(method: 'warning_message_invoice').save
				end
			end
		end
		#Finally, send ultimatum after 25 days
	end

	#
	# 1st of month:
	# Collect active companies that don't have months payed in advance and leave them in issued state
	# Collect companies that haven't payed last month, add to their due amount and leave them in expired state
	#
	def self.collect

		status_activo = PaymentStatus.find_by_name("Activo")
		status_emitido = PaymentStatus.find_by_name("Emitido")
		status_vencido = PaymentStatus.find_by_name("Vencido")
		plan_gratis = Plan.find_by_name("Gratis")

		collectables.where.not(payment_status_id: status_vencido.id).each do |company|

			sales_tax = company.country.sales_tax

			if company.payment_status_id == status_activo.id

				#If it was active, just substract a month and charge for current's month price
				#Change it's status to issued

				#If it had more months, just substract one

				company.months_active_left -= 1

				if company.months_active_left <= 0
					company.months_active_left = 0
					company.payment_status_id = status_emitido.id
					company.due_date = DateTime.now
				end

				if company.save
					CompanyCronLog.create(company_id: company.id, action_ref: 1, details: "OK substract_month")
					if company.payment_status_id == PaymentStatus.find_by_name("Emitido").id && company.country_id == 1
						company.sendings.build(method: 'invoice').save
					end
				else
					errors = ""
					company.errors.full_messages.each do |error|
						errors += error
					end
					CompanyCronLog.create(company_id: company.id, action_ref: 1, details: "ERROR substract_month "+errors)
				end


			elsif company.payment_status_id == status_emitido.id

				#If it was created within the last 2 months, it just got out of trial
				#Check for use

				#Check if account was used.


				#If it was issued, the company is late 1 month in their payments
				#Change their status to expired, add to their due and charge them for next month

				company.months_active_left = 0
				company.payment_status_id = status_vencido.id
				if company.due_amount.nil?
					if company.plan.custom
						company.due_amount = company.company_plan_setting.base_price * (1 + sales_tax)
					else
						company.due_amount = company.company_plan_setting.base_price * company.computed_multiplier * (1 + sales_tax)
					end
				else
					if company.plan.custom
						company.due_amount += company.company_plan_setting.base_price * (1 + sales_tax)
					else
						company.due_amount += company.company_plan_setting.base_price * company.computed_multiplier * (1 + sales_tax)
					end
				end
				company.due_date = DateTime.now
				company.save

				#Send invoice_email
				if !company.account_used_all
					company.sendings.build(method: 'recovery_trial').save
				else
					company.sendings.build(method: 'insistence_message_invoice').save
				end


			end

		end

		#Collect for former_trials too, but don't send them an email
		former_trials.each do |company|

			sales_tax = company.country.sales_tax

			if company.payment_status_id == status_activo.id

				#If it was active, just substract a month and charge for current's month price
				#Change it's status to issued

				#If it had more months, just substract one

				company.months_active_left -= 1

				if company.months_active_left <= 0
					company.months_active_left = 0
					company.payment_status_id = status_emitido.id
					company.due_date = DateTime.now
				end

				if company.save
					CompanyCronLog.create(company_id: company.id, action_ref: 1, details: "OK substract_month")
					if company.payment_status_id == PaymentStatus.find_by_name("Emitido").id && company.country_id == 1
						company.sendings.build(method: 'invoice').save
					end
				else
					errors = ""
					company.errors.full_messages.each do |error|
						errors += error
					end
					CompanyCronLog.create(company_id: company.id, action_ref: 1, details: "ERROR substract_month "+errors)
				end

			elsif company.payment_status_id == status_emitido.id

				company.months_active_left = 0
				company.payment_status_id = status_emitido.id
				if company.due_amount.nil?
					if company.plan.custom
						company.due_amount = company.company_plan_setting.base_price * (1 + sales_tax)
					else
						company.due_amount = company.company_plan_setting.base_price * company.computed_multiplier * (1 + sales_tax)
					end
				else
					if company.plan.custom
						company.due_amount += company.company_plan_setting.base_price * (1 + sales_tax)
					else
						company.due_amount += company.company_plan_setting.base_price * company.computed_multiplier * (1 + sales_tax)
					end
				end
				company.due_date = DateTime.now
				company.save

			end

		end

	end

	#
	# 5th of month:
	# Remind companies that were issued and haven't payed yet
	#
	#
	def self.collect_reminder

		status_activo = PaymentStatus.find_by_name("Activo")
		status_emitido = PaymentStatus.find_by_name("Emitido")
		status_vencido = PaymentStatus.find_by_name("Vencido")
		status_bloqueado = PaymentStatus.find_by_name("Bloqueado")
		plan_gratis = Plan.find_by_name("Gratis")
		chile = Country.find_by_name("Chile")

		month_day = Time.now.day
		month_end = Time.now.days_in_month
		month_prop = (month_day - 1).to_f / month_end.to_f

		collectables.where(payment_status_id: status_emitido.id).each do |company|

			sales_tax = company.country.sales_tax

			#Send first reminder
			if !company.account_used_all
				#Hasn't used
			else
				company.sendings.build(method: 'message_invoice').save
			end


		end

	end

	#10th of month
	#Soft block companies that where in Vencido
	def self.collect_block
		status_vencido = PaymentStatus.find_by_name("Vencido")
		status_bloqueado = PaymentStatus.find_by_name("Bloqueado")
		plan_gratis = Plan.find_by_name("Gratis")
		chile = Country.find_by_name("Chile")

		month_day = Time.now.day
		month_end = Time.now.days_in_month
		month_prop = (month_day - 1).to_f / month_end.to_f

		collectables.where(payment_status_id: status_vencido.id).each do |company|

			sales_tax = company.country.sales_tax

			#Block them by changing their plan to free plan
			#Add their due amount for possible reactivation in the future

			#prev_plan_id = company.plan_id

			company.payment_status_id = status_bloqueado.id
			if company.due_amount.nil?
				if company.plan.custom
					#company.due_amount = month_prop * company.plan.plan_countries.find_by(country_id: company.country.id).price.to_f * (1 + sales_tax)
					company.due_amount = month_prop * company.company_plan_setting.base_price * (1 + sales_tax)
				else
					company.due_amount = month_prop * company.company_plan_setting.base_price * company.computed_multiplier * (1 + sales_tax)
				end
			else
				#company.due_amount += month_prop * company.plan.plan_countries.find_by(country_id: company.country.id).price.to_f * (1 + sales_tax)
				if company.plan.custom
					#company.due_amount = month_prop * company.plan.plan_countries.find_by(country_id: company.country.id).price.to_f * (1 + sales_tax)
					company.due_amount += month_prop * company.company_plan_setting.base_price * (1 + sales_tax)
				else
					company.due_amount += month_prop * company.company_plan_setting.base_price * company.computed_multiplier * (1 + sales_tax)
				end
			end
			#company.plan_id = plan_gratis.id
			company.due_date = DateTime.now

			if company.save
				#DowngradeLog.create(company_id: company.id, debt: company.due_amount, plan_id: prev_plan_id)
				#Send mail alerting their plan changed
				if company.account_used_all
					company.sendings.build(method: 'close_message_invoice').save
				end
			end


		end

	end

	#15th of month
	#Remind Emitidos
	#Shut down (set inactivo) Bloqueados
	def self.collect_insistence

		status_activo = PaymentStatus.find_by_name("Activo")
		status_emitido = PaymentStatus.find_by_name("Emitido")
		status_vencido = PaymentStatus.find_by_name("Vencido")
		status_inactivo = PaymentStatus.find_by_name("Inactivo")
		plan_gratis = Plan.find_by_name("Gratis")

		collectables.where(payment_status_id: status_emitido.id).each do |company|

			#Send second reminder (insistence)
			if !company.account_used_all
				company.sendings.build(method: 'recovery_trial').save
			else
				company.sendings.build(method: 'reminder_message_invoice').save
			end

		end

		#Shut down blocked companies
		regular_blocked.each do |company|
			company.payment_status_id = status_inactivo.id
			company.active = false
			company.save
		end

	end

	#25th of month
	def self.collect_ultimatum

		status_activo = PaymentStatus.find_by_name("Activo")
		status_emitido = PaymentStatus.find_by_name("Emitido")
		status_vencido = PaymentStatus.find_by_name("Vencido")
		plan_gratis = Plan.find_by_name("Gratis")

		message_emitido = "Tu cuenta fue enviada el 1° del mes. Si no cancelas el mes en curso dentro de los próximos días, tu plan actual será desactivado y sólo tendrás acceso básico a tu calendario. Por favor paga a la brevedad para que no tengas problemas con tu servicio"

		collectables.where(payment_status_id: status_emitido.id).each do |company|

			#Send ultimatum saying they will be downgraded on failure to pay
			if !company.account_used_all
				#Hasn't used
			else
				company.sendings.build(method: 'warning_message_invoice').save
			end

		end

	end

	#Return an array containing
	#response[0] = Last payment date (or "No existen pagos" if nil)
	#response[1] = Last payment amount (or 0 if nil)
	def last_payment_detail

		bl = BillingLog.where.not(transaction_type_id: TransactionType.find_by_name("Transferencia Formulario").id).where(:company_id => self.id).where('trx_id in (?) or trx_id in (?)', PuntoPagosConfirmation.where(:response => "00").pluck(:trx_id), PayUNotification.where(:state_pol => "4").pluck(:reference_sale)).order('created_at desc').first
		rec = BillingRecord.where(:company_id => self.id).order('date desc').first
		bwt = BillingWireTransfer.where(:company_id => self.id, :approved => true).order('payment_date desc').first
		pl = PlanLog.where(:company_id => self.id).where('trx_id in (?) or trx_id in (?)', PuntoPagosConfirmation.where(:response => "00").pluck(:trx_id), PayUNotification.where(:state_pol => "4").pluck(:reference_sale)).order('created_at desc').first

		last_payment_date = ""
		paid_amount = "0"
		last_payment_method = ""

		if bl.nil? && rec.nil? && bwt.nil? && pl.nil?

			last_payment_date = "No existen pagos"
			response_array = []
			response_array[0] = last_payment_date
			response_array[1] = paid_amount
			response_array[2] = last_payment_method

			return response_array

		else

			date1 = Time.at(0).to_datetime
			date2 = date1
			date3 = date1
			date4 = date1

		end

		if !bl.nil?
		  date1 = bl.created_at + self.country.timezone_offset.hours
		end
		if !rec.nil?
		  date2 = rec.date.to_datetime
		end
		if !bwt.nil?
		  date3 = bwt.payment_date
		end
		if !pl.nil?
		  date4 = pl.created_at + self.country.timezone_offset.hours
		end

		if date1 >= date2 && date1 >= date3 && date1 >= date4
		  last_payment_date = bl.created_at.strftime('%d/%m/%Y %R')
		  paid_amount = "$" + bl.payment.to_s
		  last_payment_method = "Automático"
		elsif date2 >= date1 && date2 >= date3 && date2 >= date4
		  last_payment_date = rec.date.strftime('%d/%m/%Y %R')
		  paid_amount = "$" + rec.amount.to_s
		  last_payment_method = "Manual - " + (rec.transaction_type ? rec.transaction_type.name : "No definido")
		elsif date3 >= date1 && date3 >= date2 && date3 >= date4
		  last_payment_date = bwt.payment_date.strftime('%d/%m/%Y %R')
		  paid_amount = "$" + bwt.amount.to_s
		  last_payment_method = "Transferencia"
		else
		  last_payment_date = pl.created_at.strftime('%d/%m/%Y %R')
		  paid_amount = "$" + pl.amount.to_s
		  last_payment_method = "Automático"
		end

		response_array = []
		response_array[0] = last_payment_date
		response_array[1] = paid_amount
		response_array[2] = last_payment_method

		return response_array

	end

	def reached_mailing_limit?
		self.settings.monthly_mails >= self.settings.get_mails_capacity #plan.monthly_mails
	end

	def mails_left
		self.settings.get_mails_capacity - self.settings.monthly_mails
	end

	def web_url
		countries = self.company_countries.where(country_id: Country.find_by(locale: I18n.locale.to_s)).first
		countries = self.company_countries.first if countries.blank?
		"#{countries.web_address}.agendapro#{countries.country.domain}"
	end

	def self.generate_bookings_report(company_id, location_ids, from, to, option, status_ids, filepath)
	    require 'writeexcel'

	    header = []

	    if option.to_i == 0
        	bookings = Booking.where(created_at: from..to, status_id: status_ids, location_id: location_ids).where('is_session = false or (is_session = true and is_session_booked = true)').order(created_at: :desc)
        	header << "Fecha de creación"
        	header << "Fecha de realización"
      	else
        	bookings = Booking.where(start: from..to, status_id: status_ids, location_id: location_ids).where('is_session = false or (is_session = true and is_session_booked = true)').order(start: :desc)
        	header << "Fecha de realización"
        	header << "Fecha de creación"
      	end

	    company = Company.find(company_id)
	    title = filepath
	    workbook = WriteExcel.new(title)

	    worksheet = workbook.add_worksheet


	    header = header + ["Local", "Cliente", "Servicio", "Precio lista", "Precio real", "Nº de sesión", "Prestador", "Estado", "Estado de pago", "Notas compartidas con cliente", "Comentario interno"]

	    worksheet.write_row(0, 0, header)

	    bookings.each_with_index do |booking, index|

	    	booking_date = ""
	    	payed_state = ""
	    	session_number = "NA"
	    	booking_client = "Sin información"
	    	if !booking.client.nil?
	    		booking_client = booking.client.full_name
	    	end

	    	if !booking.payed_booking.nil?
                payed_state = "Pagada (en línea)"
            elsif !booking.payment.nil?
                payed_state = "Pagada (pago asociado)"
            elsif booking.payed_state
                payed_state = "Pagada"
            else
                payed_state = "No pagada"
            end

	    	if option.to_i == 0
	    		booking_date1 = booking.created_at.strftime('%d/%m/%Y %R')
	    		booking_date2 = booking.start.strftime('%d/%m/%Y %R')
	    	else
	    		booking_date1 = booking.start.strftime('%d/%m/%Y %R')
	    		booking_date2 = booking.created_at.strftime('%d/%m/%Y %R')
	    	end

	    	if booking.is_session && !booking.session_booking.nil?
	    		session_number = (booking.session_booking.bookings.where(is_session_booked: true).where('start < ?', booking.start).count + 1).to_s
	    	end

	    	booking_row = [booking_date1, booking_date2, booking.location.name, booking_client, booking.service.name, booking.list_price, booking.price, session_number, booking.service_provider.public_name, booking.status.name, payed_state, booking.notes, booking.company_comment]

	    	worksheet.write_row(index+1, 0, booking_row)

	    end

	    workbook.close

	    return workbook

	end

	def self.generate_clients_file(company_id, clients, filepath)
		require 'writeexcel'
	    header = []

	    company = Company.find(company_id)

	    title = filepath
	    workbook = WriteExcel.new(title)

	    worksheet = workbook.add_worksheet

	    header = ["E-mail", "Nombre", "Apellido", (I18n.t('ci')).capitalize, "Teléfono", "Dirección", "Comuna", "Fecha Nacimiento", "Edad", "Género", "Fecha Creación"]

	    attributes = company.custom_attributes.joins(:attribute_group).order('attribute_groups.order asc').order('attributes.order asc').order('name asc')
		attributes.each do |attribute|
			if attribute.datatype != "file"
				if attribute.datatype != "categoric" || (attribute.datatype == "categoric" && !attribute.attribute_categories.nil? && attribute.attribute_categories.count > 0)
			    	header << attribute.name
				end
			end
		end

		worksheet.write_row(0, 0, header)

		clients.each_with_index do |client, index|

			gender = "Indefinido"
			if client.gender == 1
				gender = "Femenino"
			elsif client.gender == 2
				gender = "Masculino"
			end

			client_row = [client.email, client.first_name, client.last_name, client.identification_number, client.phone, client.address, client.district, client.get_birth_date, client.age, gender, client.created_at.strftime('%d/%m/%Y %R')]

			attributes.each do |attribute|
				if attribute.datatype != "file"
				  if attribute.datatype == "float"
				    float_attribute = FloatAttribute.where(attribute_id: attribute.id, client_id: client.id).first
				    float_attribute_value = ""
				    if !float_attribute.nil? && !float_attribute.value.nil?
				      float_attribute_value = float_attribute.value
				    end
				    client_row << float_attribute_value.to_s
				  elsif attribute.datatype == "integer"
				    integer_attribute = IntegerAttribute.where(attribute_id: attribute.id, client_id: client.id).first
				    integer_attribute_value = ""
				    if !integer_attribute.nil? && !integer_attribute.value.nil?
				      integer_attribute_value = integer_attribute.value
				    end
				    client_row << integer_attribute_value.to_s
				  elsif attribute.datatype == "text"
				    text_attribute = TextAttribute.where(attribute_id: attribute.id, client_id: client.id).first
				    text_attribute_value = ""
				    if !text_attribute.nil? && !text_attribute.value.nil?
				      text_attribute_value = text_attribute.value
				    end
				    client_row << text_attribute_value
				  elsif attribute.datatype == "textarea"
				    textarea_attribute = TextareaAttribute.where(attribute_id: attribute.id, client_id: client.id).first
				    textarea_attribute_value = ""
				    if !textarea_attribute.nil? && !textarea_attribute.value.nil?
				      textarea_attribute_value = textarea_attribute.value
				    end
				    client_row << textarea_attribute_value
				  elsif attribute.datatype == "boolean"
				    boolean_attribute = BooleanAttribute.where(attribute_id: attribute.id, client_id: client.id).first
				    boolean_attribute_value = ""
				    if !boolean_attribute.nil? && !boolean_attribute.value.nil?
				      if boolean_attribute.value == true
				        boolean_attribute_value = "Sí"
				      else
				        boolean_attribute_value = "No"
				      end
				    end
				    client_row << boolean_attribute_value
				  elsif attribute.datatype == "date"
				    date_attribute = DateAttribute.where(attribute_id: attribute.id, client_id: client.id).first
				    date_attribute_value = ""
				    if !date_attribute.nil? && !date_attribute.value.nil?
				      date_attribute_value = date_attribute.value.strftime('%d/%m/%Y')
				    end
				    client_row << date_attribute_value
				  elsif attribute.datatype == "datetime"
				    date_time_attribute = DateTimeAttribute.where(attribute_id: attribute.id, client_id: client.id).first
				    date_time_attribute_date = ""
				    date_time_attribute_hour = "00"
				    date_time_attribute_minute = "00"
				    if !date_time_attribute.nil? && !date_time_attribute.value.nil?
				      date_time_attribute_value = date_time_attribute.value.strftime("%d/%m/%Y %R")
				    end
				    client_row << date_time_attribute_value
				  elsif attribute.datatype == "categoric" && !attribute.attribute_categories.nil? && attribute.attribute_categories.count > 0
				    categoric_attribute = CategoricAttribute.where(attribute_id: attribute.id, client_id: client.id).first
				    category_value = ""
				    if !categoric_attribute.nil? && !categoric_attribute.attribute_category.nil?
				      category_value = categoric_attribute.attribute_category.category
				    end
				    client_row << category_value
				  end
				end
			end

			worksheet.write_row(index+1, 0, client_row)

		end

		workbook.close

	    return workbook

	end

	def self.delete_booking_file(filepath)
		File.delete(filepath)
	end

end
