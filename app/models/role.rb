class Role < ActiveRecord::Base
	has_many :users
	has_many :staffs

	validates :name, :description, :presence => true
end
