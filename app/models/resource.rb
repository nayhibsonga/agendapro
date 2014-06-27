class Resource < ActiveRecord::Base
  belongs_to :resource_category
  belongs_to :company

  has_many :service_resources
  has_many :services, :through => :service_resources

  has_many :resource_locations
  has_many :locations, :through => :resource_locations
end
