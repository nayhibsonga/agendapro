class AttributeCategory < ActiveRecord::Base
	belongs_to :attribute
	has_many :categoric_attributes
end
