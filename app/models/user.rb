class User < ActiveRecord::Base
	belongs_to :role

	has_many :bookings
	has_many :staffs

	validates :first_name, :last_name, :email, :phone, :user_name, :password, :presence => true
end
