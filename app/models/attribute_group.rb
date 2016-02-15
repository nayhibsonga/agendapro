class AttributeGroup < ActiveRecord::Base
	belongs_to :company
	has_many :custom_attributes, foreign_key: 'company_id', class_name: 'Attribute'
end
