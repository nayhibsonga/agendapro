class Plan < ActiveRecord::Base
	has_many :companies, dependent: :restrict_with_error
	
	belongs_to :plan_log

	validates :name, :locations, :service_providers, :presence => true
end
