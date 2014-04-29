class Plan < ActiveRecord::Base
	has_many :companies
	
	belongs_to :plan_log

	validates :name, :locations, :service_providers, :presence => true
end
