class Attribute < ActiveRecord::Base
	belongs_to :company
	has_many :attribute_categories

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
