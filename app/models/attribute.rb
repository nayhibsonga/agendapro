class Attribute < ActiveRecord::Base

	belongs_to :company

	has_many :attribute_categories, dependent: :destroy
	has_many :float_attributes, dependent: :destroy
	has_many :integer_attributes, dependent: :destroy
	has_many :text_attributes, dependent: :destroy
	has_many :boolean_attributes, dependent: :destroy
	has_many :date_attributes, dependent: :destroy
	has_many :date_time_attributes, dependent: :destroy
	has_many :file_attributes, dependent: :destroy
	has_many :categoric_attributes, dependent: :destroy
	has_many :textarea_attributes, dependent: :destroy

	after_create :create_clients_attributes
	after_save :check_file
	after_save :generate_slug

	def generate_slug
		new_slug = self.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').squish.downcase.tr(" ","_").to_s
		self.update_column(:slug, new_slug)
	end

	def check_file
		self.update_column(:show_on_calendar, false)
		self.update_column(:show_on_workflow, false)
		self.update_column(:mandatory_on_calendar, false)
		self.update_column(:mandatory_on_workflow, false)
	end

	def create_clients_attributes

		if self.datatype == "categoric"
			attribute_category = AttributeCategory.create(attribute_id: self.id, category: "Otra")
		end


		company = self.company
		company.clients.each do |client|
			case self.datatype
			when "float"
				
				if FloatAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					FloatAttribute.create(attribute_id: self.id, client_id: client.id)
				end

			when "integer"
				
				if IntegerAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					IntegerAttribute.create(attribute_id: self.id, client_id: client.id)
				end

			when "text"
				
				if TextAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					TextAttribute.create(attribute_id: self.id, client_id: client.id)
				end

			when "textarea"
				
				if TextareaAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					TextareaAttribute.create(attribute_id: self.id, client_id: client.id)
				end

			when "boolean"
				
				if BooleanAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					BooleanAttribute.create(attribute_id: self.id, client_id: client.id)
				end

			when "date"
				
				if DateAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					DateAttribute.create(attribute_id: self.id, client_id: client.id)
				end

			when "datetime"
				
				if DateTimeAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					DateTimeAttribute.create(attribute_id: self.id, client_id: client.id)
				end

			when "file"
				if FileAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					FileAttribute.create(attribute_id: self.id, client_id: client.id)
				end
			when "categoric"
				if CategoricAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					CategoricAttribute.create(attribute_id: self.id, client_id: client.id, attribute_category_id: attribute_category.id)
				end
			end
		end

	end

	def datatype_to_text
		case self.datatype
		when "float"
			return "Decimal"
		when "integer"
			return "Númerico"
		when "text"
			return "Texto"
		when "textarea"
			return "Área de texto"
		when "boolean"
			return "Binario (Sí/No)"
		when "date"
			return "Fecha"
		when "datetime"
			return "Fecha y hora"
		when "file"
			return "Archivo"
		when "categoric"
			return "Categórico"
		end
	end

	def text_to_datatype

	end

	def mandatory_to_text
		if self.mandatory
			return "Sí"
		end
		return "No"
	end

	def check_categories(cat_str)
		if self.datatype != "categoric"
			return nil
		elsif cat_str.nil? || cat_str == ""
			return self.attribute_categories.find_by_category("Otra").id
		else
			self.attribute_categories.each do |category|
				if cat_str.downcase == category.category.downcase
					return category.id
				end
			end
			return self.attribute_categories.find_by_category("Otra").id
		end
	end

end
