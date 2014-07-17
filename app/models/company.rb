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
	has_many :company_from_email, dependent: :destroy

	validates :name, :web_address, :economic_sector, :plan, :payment_status, :presence => true

	validates_uniqueness_of :web_address

	mount_uploader :logo, LogoUploader

	accepts_nested_attributes_for :company_setting
end
