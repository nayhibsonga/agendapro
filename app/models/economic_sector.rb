class EconomicSector < ActiveRecord::Base
	has_many :companies
	has_many :tags

	validates :name, :presence => true
end
