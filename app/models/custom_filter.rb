class CustomFilter < ActiveRecord::Base
	
	belongs_to :company

	has_many :numeric_custom_filters
	has_many :categoric_custom_filters
	has_many :date_custom_filters
	has_many :text_custom_filters
	has_many :boolean_custom_filters

end
