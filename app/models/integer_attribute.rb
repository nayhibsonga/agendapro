class IntegerAttribute < ActiveRecord::Base
	belongs_to :attribute
	belongs_to :client
end
