class Day < ActiveRecord::Base
	has_many :provider_times, dependent: :destroy
	has_many :location_times, dependent: :destroy

	validates :name, :presence => true
end
