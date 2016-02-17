class AttributeGroup < ActiveRecord::Base
	belongs_to :company
	has_many :custom_attributes, foreign_key: 'attribute_group_id', class_name: 'Attribute'

	after_save :rearrange

	def rearrange

		#Check order isn't past current gratest order
		greatest_order = AttributeGroup.where(company_id: self.company_id).maximum(:order)
		
		if greatest_order.nil?
			greatest_order = 0
		end

		if self.order.nil? || self.order > greatest_order + 1
			self.update_column(:order, greatest_order + 1)
		end

		#Check if order exists and rearrange
		if AttributeGroup.where(company_id: self.company_id, order: self.order).where.not(id: self.id).count > 0
			later_groups = AttributeGroup.where(company_id: self.company_id).where('attribute_groups.order >= ?', self.order).where.not(id: self.id)
			later_groups.each do |att_group|
				att_group.update_column(:order, att_group.order + 1)
			end
		end
	end

	def get_greatest_order
		return AttributeGroup.where(company_id: self.company_id).maximum(:order)
	end

	def get_attributes_greatest_order
		if self.custom_attributes.count < 1
			return 0
		end
		greatest_order = self.custom_attributes.maximum(:order)
		if greatest_order.nil?
			greatest_order = 0
		end
		return greatest_order
	end

end
