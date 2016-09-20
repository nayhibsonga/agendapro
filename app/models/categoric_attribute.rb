class CategoricAttribute < ActiveRecord::Base
	
	belongs_to :client
	belongs_to :attribute
	belongs_to :attribute_category

end
