class ProviderBreak < ActiveRecord::Base
  belongs_to :service_provider

  validates :start, :end, :presence => true
end
