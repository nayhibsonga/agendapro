class Company < ActiveRecord::Base

	belongs_to :plan
	belongs_to :payment_status
	belongs_to :country

	has_many :company_economic_sectors
	has_many :economic_sectors, :through => :company_economic_sectors

	has_many :company_countries
	has_many :countries, :through => :company_countries

	has_many :cashiers, dependent: :destroy

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

	validates :name, :web_address, :plan, :payment_status, :country, :presence => true

	validates_uniqueness_of :web_address, scope: :country_id

	mount_uploader :logo, LogoUploader

	accepts_nested_attributes_for :company_setting

	validate :plan_settings

	after_update :update_online_payment

	def plan_settings
		if self.locations.where(active: true).count > self.plan.locations || self.service_providers.where(active: true).count > self.plan.service_providers
			errors.add(:base, "El plan no pudo ser cambiado. Tienes más locales/prestadores activos que lo que permite el plan.")
		end
	end

	def secret_code
		crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
		encrypted_data = crypt.encrypt_and_sign(self.id.to_s)
		return encrypted_data
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
					CompanyMailer.invoice_email(company.id)
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
					CompanyMailer.invoice_email(company.id)
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
			company.due_amount = 0.0
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

	def self.end_trial
		month_days = Time.now.days_in_month
		where(payment_status_id: PaymentStatus.find_by_name("Trial").id).where('created_at <= ?', 1.months.ago).each do |company|
			plan_id = Plan.where(custom: false).where('locations >= ?', company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.id
			company.plan_id = plan_id
			company.due_date = Time.now
			company.payment_status_id = PaymentStatus.find_by_name("Emitido").id
			if company.save
				CompanyCronLog.create(company_id: company.id, action_ref: 5, details: "OK end_trial")
				if company.country_id == 1
					CompanyMailer.invoice_email(company.id)
				end
			else
				errors = ""
				company.errors.full_messages.each do |error|
					errors += error
				end
				CompanyCronLog.create(company_id: company.id, action_ref: 5, details: "ERROR end_trial "+errors)
			end
		end
	end

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
			CompanyMailer.invoice_email(company.id)
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

end
