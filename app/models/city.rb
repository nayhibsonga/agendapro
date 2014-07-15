class City < ActiveRecord::Base
	has_many :districts, dependent: :destroy

	belongs_to :region

	validates :name, :presence => true
end
