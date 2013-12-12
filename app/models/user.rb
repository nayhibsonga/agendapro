class User < ActiveRecord::Base
	belongs_to :role

	has_many :bookings
	has_one :staffs

	validates :first_name, :last_name, :email, :phone, :presence => true
end
