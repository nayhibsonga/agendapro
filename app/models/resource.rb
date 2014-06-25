class Resource < ActiveRecord::Base
  belongs_to :location

  has_many :service_resources
  has_many :services, :through => :service_resources
end
