class AttributeCategory < ActiveRecord::Base
	belongs_to :attribute
	has_many :categoric_attributes

	before_destroy :reset_client

	def reset_client

		category_otra = self.attribute.attribute_categories.where(category: "Otra").first

		self.attribute.company.clients.each do |client|
			categoric_attribute = CategoricAttribute.where(client_id: client.id, attribute_id: self.attribute_id).first
			categoric_attribute.attribute_category_id = category_otra.id
			categoric_attribute.save
		end
	end

end
