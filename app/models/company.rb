class Company < ActiveRecord::Base
	belongs_to :economic_sector
	belongs_to :plan
	belongs_to :payment_status

	has_many :users, dependent: :nullify
	has_many :plan_logs, dependent: :destroy
	has_many :billing_logs, dependent: :destroy
	has_many :services, dependent: :destroy
	has_many :service_providers, dependent: :destroy
	has_many :locations, dependent: :destroy
	has_many :service_categories, dependent: :destroy
	has_many :clients, dependent: :destroy
	has_one :company_setting, dependent: :destroy
	has_one :billing_info, dependent: :destroy
	has_many :company_from_email, dependent: :destroy

	validates :name, :web_address, :economic_sector, :plan, :payment_status, :presence => true

	validates_uniqueness_of :web_address

	mount_uploader :logo, LogoUploader

	accepts_nested_attributes_for :company_setting

	validate :plan_settings

	def plan_settings
		if self.locations.where(active: true).count > self.plan.locations || self.service_providers.where(active: true).count > self.plan.service_providers
			errors.add(:base, "El plan no pudo ser cambiado. Tienes más locales/proveedores activos que lo que permite el plan.")
		end
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
			comapny.due_amount = 0.0
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
			plan_id = Plan.where(custom: false).where('locations >= ?', company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:price).first.id
			company.plan_id = plan_id
			company.due_date = Time.now
			company.payment_status_id = PaymentStatus.find_by_name("Emitido").id
			if company.save
				CompanyCronLog.create(company_id: company.id, action_ref: 5, details: "OK end_trial")
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
			company.due_amount += company.plan.price/month_days
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
end
