class TextareaAttribute < ActiveRecord::Base
	belongs_to :attribute
	belongs_to :client
end
