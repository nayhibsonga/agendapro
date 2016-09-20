class Role < ActiveRecord::Base
	has_many :users, dependent: :destroy

	validates :name, :description, :presence => true
end
