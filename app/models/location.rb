class Location < ActiveRecord::Base

	belongs_to :district
	belongs_to :company

	has_many :location_times
	has_many :service_providers
	has_many :bookings

	validates :name, :address, :phone, :company, :district, :presence => true
end
