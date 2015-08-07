class ServicePromo < ActiveRecord::Base
	has_many :promos
	has_many :bookings
	has_many :session_bookings
end
