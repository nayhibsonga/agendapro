class EconomicSector < ActiveRecord::Base
	has_many :companies
	has_many :tags
	has_many :economic_sectors_dictionaries

	accepts_nested_attributes_for :economic_sectors_dictionaries, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :presence => true
end
