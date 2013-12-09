class Promotion < ActiveRecord::Base
	has_one :booking

	validates :code, :presence => true
end
