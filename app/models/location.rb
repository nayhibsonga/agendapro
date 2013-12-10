class Location < ActiveRecord::Base

	belongs_to :district
	belongs_to :company

	has_many :location_times
	has_many :staffs
	has_many :bookings

	validates :name, :address, :phone, :presence => true
end
