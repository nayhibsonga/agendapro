class TreatmentPromo < ActiveRecord::Base
	belongs_to :service
	has_many :treatment_promo_locations
	has_many :locations, :through => :treatment_promo_locations
end
