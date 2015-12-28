class ServiceBundle < ActiveRecord::Base
  belongs_to :service
  belongs_to :bundle

  validates :order, :bundle, :service, :presence => true
end
