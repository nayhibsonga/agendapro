class ProviderTime < ActiveRecord::Base
	belongs_to :day
	belongs_to :service_provider, :inverse_of => :provider_times

	validates :open, :close, :presence => true
end
