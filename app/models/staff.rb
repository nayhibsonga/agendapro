class Staff < ActiveRecord::Base
	belongs_to :location
	belongs_to :role
	belongs_to :user

	has_many :services, :through => :services_staffs
	has_many :staff_times
	has_many :bookings
	
end
