class PlanCountry < ActiveRecord::Base
  belongs_to :plan
  belongs_to :country

  validates :plan, :country, :price, :presence => true

  validates_uniqueness_of :plan_id, scope: :country_id
end
