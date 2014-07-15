class EconomicSector < ActiveRecord::Base
	has_many :companies, dependent: :restrict_with_error
	has_many :tags, dependent: :destroy
	has_many :economic_sectors_dictionaries, dependent: :destroy

	accepts_nested_attributes_for :economic_sectors_dictionaries, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :presence => true
end
