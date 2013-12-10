class Region < ActiveRecord::Base
	has_many :cities

	belongs_to :country

	validates :name, :presence => true
end
