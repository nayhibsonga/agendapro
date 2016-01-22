class Country < ActiveRecord::Base
	has_many :regions, dependent: :destroy
	has_many :companies, dependent: :restrict_with_error

	has_many :plan_countries
	has_many :plans, through: :plan_countires

	validates :name, :locale, :currency_code, :latitude, :longitude, :formatted_address, :domain, :sales_tax, :presence => true

	mount_uploader :flag_photo, CountryUploader
end
