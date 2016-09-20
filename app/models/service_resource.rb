class ServiceResource < ActiveRecord::Base
  belongs_to :service
  belongs_to :resource
end
