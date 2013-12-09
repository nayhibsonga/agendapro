class Booking < ActiveRecord::Base
	belongs_to :staff
	belongs_to :user
	belongs_to :status
	belongs_to :location
	belongs_to :promotion

	validates :start, :end, :presence => true
end
