class Company < ActiveRecord::Base
	belongs_to :economic_sector
	belongs_to :plan
	belongs_to :payment_status

	has_many :users
	has_many :plan_logs
	has_many :billing_logs
	has_many :services
	has_many :service_providers
	has_many :locations
	has_many :service_categories
	has_many :clients
	has_one :company_setting
	has_one :billing_info
	has_many :company_from_email

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
end
