class LocationTime < ActiveRecord::Base
	belongs_to :day
	belongs_to :location

	validates :open, :close, :presence => true
end
