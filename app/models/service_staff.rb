class ServiceStaff < ActiveRecord::Base
	belongs_to :service
	belongs_to :staff

	validates :service, :staff, :presence => true
end
