class Plan < ActiveRecord::Base
	has_many :companies, dependent: :restrict_with_error

	has_many :plan_countries
	has_many :countries, through: :plan_countires
	
	belongs_to :plan_log

	accepts_nested_attributes_for :plan_countries, reject_if: :all_blank

	validates :name, :locations, :service_providers, :presence => true
end
