class Tag < ActiveRecord::Base
	has_many :services
	has_many :dictionaries

	belongs_to :economic_sector

	validates :name, :presence => true
end
