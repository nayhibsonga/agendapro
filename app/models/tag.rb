class Tag < ActiveRecord::Base
	has_many :service_tags
	has_many :services, :through => :service_tags
	has_many :dictionaries

	accepts_nested_attributes_for :dictionaries, :reject_if => :all_blank, :allow_destroy => true

	belongs_to :economic_sector

	validates :name, :economic_sector, :presence => true
end
