class Staff < ActiveRecord::Base
	belongs_to :location
	belongs_to :role

	has_many :services, :through => :services_staffs
	has_many :staff_times
	has_many :bookings

	validates :first_name, :last_name, :email, :phone, :user_name, :password
end
