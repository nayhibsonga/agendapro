class ServiceProvider < ActiveRecord::Base
	belongs_to :location
	belongs_to :user
	belongs_to :company

	has_many :service_staffs
	has_many :services, :through => :service_staffs
	has_many :provider_times
	has_many :bookings
	
	validates :company, :presence => true
end
