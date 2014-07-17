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

	validate :plan_settings, :due_payment

	def plan_settings
		if self.locations.where(active: true).count > self.plan.locations || self.service_providers.where(active: true).count > self.plan.service_providers
			errors.add(:base, "El plan no pudo ser cambiado. Tienes más locales/proveedores activos que lo que permite el plan.")
		end
	end

	def due_payment
		if self.due_amount != 0 && self.due_date != nil
			errors.add(:base, "La empresa no puede tener deuda activa sin una fecha de cobro, comunícate con el administrador (contacto@agendapro.cl).")
		end
	end

	def self.substract_month
		where(payment_status_id: PaymentStatus.find_by_name("Pagado")).each do |company|
			company.months_active_left -= 1.0
			if company.months_active_left <= 0
				company.payment_status_id = PaymentStatus.find_by_name("Emitido").id
			end
			company.save
		end
	end

	def self.payment_expiry
		where(payment_status_id: PaymentStatus.find_by_name("Emitido")).each do |company|
			if company.months_active_left <= 0
				company.payment_status_id = PaymentStatus.find_by_name("Vencido").id
			end
			company.save
		end
	end

	def self.payment_shut
		where(payment_status_id: PaymentStatus.find_by_name("Vencido")).each do |company|
			if company.months_active_left <= 0
				company.payment_status_id = PaymentStatus.find_by_name("Bloqueado").id
			end
			company.save
		end
	end
end
