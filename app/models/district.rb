class District < ActiveRecord::Base
	has_many :locations, dependent: :restrict_with_error

	belongs_to :city

	validates :name, :presence => true
end
