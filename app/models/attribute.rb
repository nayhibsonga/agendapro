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

	after_create :create_clients_attributes
	after_save :check_file, :generate_slug, :rearrange
	after_destroy :check_left

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

	def create_chart_field(chart_id)

		if self.datatype == "categoric"
			chart_category = ChartCategory.create(chart_field_id: self.id, category: "Otra")
		end

		case self.datatype
		when "float"
			
			if ChartFieldFloat.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldFloat.create(chart_field_id: self.id, chart_id: chart_id)
			end

		when "integer"
			
			if ChartFieldInteger.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldInteger.create(chart_field_id: self.id, chart_id: chart_id)
			end

		when "text"
			
			if ChartFieldText.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldText.create(chart_field_id: self.id, chart_id: chart_id, value: "")
			end

		when "textarea"
			
			if ChartFieldTextarea.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldTextarea.create(chart_field_id: self.id, chart_id: chart_id, value: "")
			end

		when "boolean"
			
			if ChartFieldBoolean.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldBoolean.create(chart_field_id: self.id, chart_id: chart_id)
			end

		when "date"
			
			if ChartFieldDate.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldDate.create(chart_field_id: self.id, chart_id: chart_id)
			end

		when "datetime"
			
			if ChartFieldDatetime.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldDatetime.create(chart_field_id: self.id, chart_id: chart_id)
			end

		when "file"
			if ChartFieldFile.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldFile.create(chart_field_id: self.id, chart_id: chart_id)
			end
		when "categoric"
			if ChartFieldCategoric.where(chart_field_id: self.id, chart_id: chart_id).count == 0
				ChartFieldCategoric.create(chart_field_id: self.id, chart_id: chart_id, chart_category_id: chart_category.id)
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
			self.chart_categories.each do |category|
				if cat_str.downcase == category.category.downcase
					return category.id
				end
			end
			return nil
		end
	end

end
