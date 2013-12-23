class ServiceProvider < ActiveRecord::Base
	belongs_to :location
	belongs_to :user
	belongs_to :company

	has_many :services, :through => :services_staffs
	has_many :provider_times
	has_many :bookings

	accepts_nested_attributes_for :provider_times, :reject_if => :all_blank, :allow_destroy => true
	
	validates :company, :presence => true
end
