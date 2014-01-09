class Service < ActiveRecord::Base
	belongs_to :company
	belongs_to :service_category

	has_many :service_tags
	has_many :tags, :through => :service_tags

	has_many :bookings
	has_many :service_staffs
	has_many :service_providers, :through => :service_staffs

	validates :name, :duration, :company, :presence => true
end
