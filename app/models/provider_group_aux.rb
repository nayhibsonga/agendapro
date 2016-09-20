class ProviderGroupAux < ActiveRecord::Base
  belongs_to :provider_group
  belongs_to :service_provider
end
