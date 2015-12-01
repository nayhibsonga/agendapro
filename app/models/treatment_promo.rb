class TreatmentPromo < ActiveRecord::Base
	belongs_to :service
	belongs_to :location
end
