class ServiceStaff < ActiveRecord::Base
	belongs_to :service
	belongs_to :service_provider

	validates :service, :service_provider, :presence => true
end
