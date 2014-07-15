class Status < ActiveRecord::Base
	has_many :bookings, dependent: :destroy

	validates :name, :description, :presence => true
end
