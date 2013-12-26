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
	has_one :company_setting

	validates :name, :web_address, :economic_sector, :plan, :payment_status, :presence => true

	validates_uniqueness_of :web_address
end
