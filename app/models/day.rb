class Day < ActiveRecord::Base
	has_many :staff_times
	has_many :location_times

	validates :name, :presence => true
end
