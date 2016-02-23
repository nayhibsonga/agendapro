class CustomFilter < ActiveRecord::Base
	
	belongs_to :company

	has_many :numeric_custom_filters, dependent: :destroy
	has_many :categoric_custom_filters, dependent: :destroy
	has_many :date_custom_filters, dependent: :destroy
	has_many :text_custom_filters, dependent: :destroy
	has_many :boolean_custom_filters, dependent: :destroy

	def create_filters(params)

		if params.blank?
	    	return
	    end

	    #str_sm = attribute.slug + "_attribute"

		

		self.company.custom_attributes.each do |attribute|

			if attribute.datatype == "boolean"

				str_sm = "attribute_" + attribute.id.to_s + "_boolean"
				if !params.keys.include?(str_sm)
					next
				end

				param_value = params[str_sm]

				boolean_filter = BooleanCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first

				if param_value.to_i < 2
					if param_value.to_i == 0
						if boolean_filter.nil?
							boolean_filter = BooleanCustomFilter.create(custom_filter_id: self.id, attribute_id: attribute.id, option: false)
						else
							boolean_filter.option = false
							boolean_filter.save
						end
					else
						if boolean_filter.nil?
							boolean_filter = BooleanCustomFilter.create(custom_filter_id: self.id, attribute_id: attribute.id, option: true)
						else
							boolean_filter.option = true
							boolean_filter.save
						end
					end
				else
					if !boolean_filter.nil?
						boolean_filter.destroy
					end
				end

			elsif attribute.datatype == "float" || attribute.datatype == "integer"

				str_option = "attribute_" + attribute.id.to_s + "_option"
				str_value1 = "attribute_" + attribute.id.to_s + "_value1"
				str_value2 = "attribute_" + attribute.id.to_s + "_value2"

				if !params.keys.include?(str_value1)
					next
				end

				#
				# IMPORTANT:
				#
				# Check for nulls
				#

				param_option = params[str_option]
				param_value1 = params[str_value1]
				param_value2 = params[str_value2]

				numeric_filter = NumericCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first
				if numeric_filter.nil?
					NumericCustomFilter.create(custom_filter_id: self.id, attribute_id: attribute.id, option: param_option, value1: param_value1.to_f, value2: param_value2.to_f)
				else
					numeric_filter.option = param_option
					numeric_filter.value1 = param_value1.to_f
					numeric_filter.value2 = param_value2.to_f
				end


			elsif attribute.datatype == "date"
			
			elsif attribute.datatype == "datetime"

			elsif attribute.datatype == "categoric"

			end

		end

	end

end
