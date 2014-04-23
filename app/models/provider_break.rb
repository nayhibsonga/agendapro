class ProviderBreak < ActiveRecord::Base
  belongs_to :service_provider

  validate :start, :end, :presence => true
end
