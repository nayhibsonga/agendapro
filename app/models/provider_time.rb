class ProviderTime < ActiveRecord::Base
	belongs_to :day
	belongs_to :service_provider

	validates :open, :close, :presence => true
end
