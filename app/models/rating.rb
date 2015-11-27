class Rating < ActiveRecord::Base
  belongs_to :company
  belongs_to :location
  belongs_to :service
  belongs_to :service_provider
  belongs_to :client
  belongs_to :user

  
end
