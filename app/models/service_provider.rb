class ServiceProvider < ActiveRecord::Base
	belongs_to :location
	belongs_to :user
	belongs_to :company

	has_many :services, :through => :services_staffs
	has_many :staff_times
	has_many :bookings
	
	validates :company, :presence => true
end
