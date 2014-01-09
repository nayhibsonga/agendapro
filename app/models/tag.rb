class Tag < ActiveRecord::Base
	has_many :service_tags
	has_many :services, :through => :service_tags

	belongs_to :economic_sector

	validates :name, :economic_sector, :presence => true
end
