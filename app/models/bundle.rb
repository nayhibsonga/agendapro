class Bundle < ActiveRecord::Base
  belongs_to :service_category
  belongs_to :company

  has_many :service_bundles, dependent: :destroy, :inverse_of => :bundle
  has_many :services, through: :service_bundles

  validates :name, :company, :service_category, :presence => true
  validates :price, numericality: { greater_than_or_equal_to: 0 }


  accepts_nested_attributes_for :service_bundles, :reject_if => lambda { |a| a[:service_id].blank? }, :allow_destroy => true

  after_create :update_price
  after_update :update_price

  def update_price
    self.update_columns(price: self.service_bundles.sum(:price))
  end
end
