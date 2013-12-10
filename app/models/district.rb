class District < ActiveRecord::Base
	has_many :locations

	belongs_to :city

	validates :name, :presence => true
end
