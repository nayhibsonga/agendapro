class NumericCustomFilter < ActiveRecord::Base
	belongs_to :custom_filter
	belongs_to :attribute
end
