class Bundle < ActiveRecord::Base
  belongs_to :service_category

  has_many :service_bundles, dependent: :destroy
  has_many :services, through: :service_bundles

  validates :name, :company, :service_category, :presence => true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
