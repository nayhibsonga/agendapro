class Country < ActiveRecord::Base
	has_many :locations

	validates :name, :presence => true
end
