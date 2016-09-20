class TreatmentPromoLocation < ActiveRecord::Base
	belongs_to :treatment_promo
	belongs_to :location
end
