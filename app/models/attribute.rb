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

	after_create :create_clients_attributes
	after_save :generate_slug

	def generate_slug
		new_slug = self.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').squish.downcase.tr(" ","_").to_s
		self.update_column(:slug, new_slug)
	end

	def create_clients_attributes

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
					CategoricAttribute.create(attribute_id: self.id, client_id: client.id)
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

end
