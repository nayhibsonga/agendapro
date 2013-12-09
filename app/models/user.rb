class User < ActiveRecord::Base
	belongs_to :role

	has_many :bookings

	validates :first_name, :last_name, :email, :phone, :user_name, :password, :presence => true
end
