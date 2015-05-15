class SessionBooking < ActiveRecord::Base
	has_many :bookings
	belongs_to :service
	belongs_to :user
	belongs_to :client
end
