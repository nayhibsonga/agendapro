class PlanCountry < ActiveRecord::Base
  belongs_to :plan
  belongs_to :country

  validates :country, :price, :presence => true

  validates_uniqueness_of :plan_id, scope: :country_id
end
