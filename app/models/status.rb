class Status < ActiveRecord::Base
	has_many :bookings, dependent: :destroy

	validates :name, :description, :presence => true

	def self.bookings_count(status_id, offset, time_range_id, company_id)
		
	end

	def self.bookings_count(status_id, offset, time_range_id, company_id)

	end

	def self.bookings_count(status_id, offset, time_range_id, company_id)

	end

	def self.bookings_count(status_id, offset, time_range_id, company_id)

	end
end
