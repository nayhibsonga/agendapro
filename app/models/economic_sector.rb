class EconomicSector < ActiveRecord::Base

	has_many :company_economic_sectors
	has_many :companies, :through => :company_economic_sectors
	has_many :tags, dependent: :destroy
	has_many :economic_sectors_dictionaries, dependent: :destroy

	belongs_to :marketplace_category

	accepts_nested_attributes_for :economic_sectors_dictionaries, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :presence => true

	mount_uploader :mobile_preview, EconomicSectorUploader
end
