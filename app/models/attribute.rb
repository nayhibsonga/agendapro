class Attribute < ActiveRecord::Base

	belongs_to :company
	belongs_to :attribute_group

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

	has_many :numeric_custom_filters, dependent: :destroy
	has_many :categoric_custom_filters, dependent: :destroy
	has_many :date_custom_filters, dependent: :destroy
	has_many :text_custom_filters, dependent: :destroy
	has_many :boolean_custom_filters, dependent: :destroy

	validate :name_uniqueness

	after_create :create_clients_attributes
	after_save :check_file, :generate_slug, :rearrange
	after_destroy :check_left

	def name_uniqueness
	    ::Attribute.where(name: self.name, company_id: self.company_id).each do |attribute|
	      	if attribute != self
	        	errors.add(:base, "No se pueden crear dos campos con el mismo nombre.")
	      	end
	    end
	end

	def check_left
		if self.company.custom_attributes.count < 1
			company.custom_filters.destroy_all
		end
	end

	def rearrange

		#Check order isn't past current gratest order
		greatest_order = ::Attribute.where(company_id: self.company_id, attribute_group_id: self.attribute_group_id).where.not(id: self.id).maximum(:order)
		if greatest_order.nil?
			greatest_order = 0
		end
		if self.order.nil? || self.order < 1 || self.order > greatest_order + 1
			self.update_column(:order, greatest_order + 1)
		end

		#Check if order exists and rearrange
		if ::Attribute.where(company_id: self.company_id, attribute_group_id: self.attribute_group_id, order: self.order).where.not(id: self.id).count > 0
			later_attributes = ::Attribute.where(company_id: self.company_id, attribute_group_id: self.attribute_group_id).where('attributes.order >= ?', self.order).where.not(id: self.id)
			later_attributes.each do |att|
				att.update_column(:order, att.order + 1)
			end
		end
	end

	def get_greatest_order
		greatest_order = ::Attribute.where(company_id: self.company_id, attribute_group_id: self.attribute_group_id).maximum(:order)
		if greatest_order.nil?
			greatest_order = 0
		end
		return greatest_order
	end

	def generate_slug
		new_slug = self.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').squish.downcase.tr(" ","_").to_s
		self.update_column(:slug, new_slug)
	end

	def check_file
		if self.datatype == "file"
			self.update_column(:show_on_calendar, false)
			self.update_column(:show_on_workflow, false)
			self.update_column(:mandatory_on_calendar, false)
			self.update_column(:mandatory_on_workflow, false)
		end
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
					TextAttribute.create(attribute_id: self.id, client_id: client.id, value: "")
				end

			when "textarea"
				
				if TextareaAttribute.where(attribute_id: self.id, client_id: client.id).count == 0
					TextareaAttribute.create(attribute_id: self.id, client_id: client.id, value: "")
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
			return nil
		else
			self.attribute_categories.each do |category|
				if cat_str.downcase == category.category.downcase
					return category.id
				end
			end
			return nil
		end
	end

end
