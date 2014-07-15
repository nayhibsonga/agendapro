class Country < ActiveRecord::Base
	has_many :regions, dependent: :destroy

	validates :name, :presence => true
end
