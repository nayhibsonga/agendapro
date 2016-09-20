class ServicePromo < ActiveRecord::Base
	has_many :promos
	has_many :bookings
end
