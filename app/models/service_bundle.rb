class ServiceBundle < ActiveRecord::Base
  belongs_to :service
  belongs_to :bundle

  validates :order, :bundle, :service, :price, :presence => true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
