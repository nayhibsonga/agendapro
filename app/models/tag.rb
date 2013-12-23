class Tag < ActiveRecord::Base
	has_many :services

	belongs_to :economic_sector

	validates :name, :presence => true
end
