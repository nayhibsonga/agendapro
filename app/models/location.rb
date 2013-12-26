class Location < ActiveRecord::Base

	belongs_to :district
	belongs_to :company

	has_many :location_times
	has_many :service_providers
	has_many :bookings

	accepts_nested_attributes_for :location_times, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :address, :phone, :company, :district, :presence => true



	def overlaps?(location1,location2)
    	(location1.open - location2.close) * (location2.open - location1.close) >= 0
  	end
end
 