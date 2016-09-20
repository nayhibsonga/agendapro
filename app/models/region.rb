class Region < ActiveRecord::Base
	has_many :cities, dependent: :destroy

	belongs_to :country

	validates :name, :presence => true
end
