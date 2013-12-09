class Status < ActiveRecord::Base
	has_many :bookings

	validates :name, :description, :presence => true
end
