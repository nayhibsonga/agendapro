class CustomFilter < ActiveRecord::Base
	
	belongs_to :company

	has_many :numeric_custom_filters, dependent: :destroy
	has_many :categoric_custom_filters, dependent: :destroy
	has_many :date_custom_filters, dependent: :destroy
	has_many :text_custom_filters, dependent: :destroy
	has_many :boolean_custom_filters, dependent: :destroy

	def create_filters(params)

		if params.blank?
			self.numeric_custom_filters.delete_all
			self.categoric_custom_filters.delete_all
			self.date_custom_filters.delete_all
			self.text_custom_filters.delete_all
			self.boolean_custom_filters.delete_all
	    	return
	    end

	    #str_sm = attribute.slug + "_attribute"

		

		self.company.custom_attributes.each do |attribute|

			#Check if it is included in the filter
			str_include = "attribute_" + attribute.id.to_s + "_include"
			param_include = params[str_include]
			puts "Checking include for " + attribute.name
			puts param_include.to_s
			if param_include.blank? || param_include.to_i == 0
				puts "Enters"
				if attribute.datatype == "boolean"
					BooleanCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).delete_all
					#if BooleanCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).count > 0
					#	BooleanCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first.destroy
					#end
				elsif attribute.datatype == "float" || attribute.datatype == "integer"
					NumericCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).delete_all
					# if NumericCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).count > 0
					# 	NumericCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first.destroy
					# end
				elsif attribute.datatype == "date" || attribute.datatype == "datetime"
					DateCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).delete_all
					# if DateCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).count > 0
					# 	DateCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first.destroy
					# end
				elsif attribute.datatype == "categoric"
					CategoricCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).delete_all
					# if CategoricCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).count > 0
					# 	CategoricCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first.destroy
					# end
				elsif attribute.datatype == "text" || attribute.datatype == "textarea"
					TextCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).delete_all
					# if TextCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).count > 0
					# 	TextCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first.destroy
					# end
				end
				next
			end

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
				str_exclusive1 = "attribute_" + attribute.id.to_s + "_exclusive1"
				str_exclusive2 = "attribute_" + attribute.id.to_s + "_exclusive2"

				if !params.keys.include?(str_value1)
					next
				end

				#
				# IMPORTANT:
				#
				# Check for nulls
				#

				param_value2 = nil

				param_option = params[str_option]
				param_value1 = params[str_value1].to_f

				if !params[str_value2].blank?
					param_value2 = params[str_value2].to_f
				end

				param_exclusive1 = params[str_exclusive1].to_i
				param_exclusive2 = params[str_exclusive2].to_i

				if param_exclusive1 == 0
					param_exclusive1 = true
				else
					param_exclusive1 = false
				end

				if param_exclusive2 == 0
					param_exclusive2 = true
				else
					param_exclusive2 = false
				end

				numeric_filter = NumericCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first
				if numeric_filter.nil?
					numeric_filter = NumericCustomFilter.create(custom_filter_id: self.id, attribute_id: attribute.id, option: param_option, value1: param_value1.to_f, value2: param_value2.to_f, exclusive1: param_exclusive1, exclusive2: param_exclusive2)
				else
					numeric_filter.option = param_option
					numeric_filter.value1 = param_value1.to_f
					numeric_filter.value2 = param_value2.to_f
					numeric_filter.exclusive1 = param_exclusive1
					numeric_filter.exclusive2 = param_exclusive2
					numeric_filter.save
				end


			elsif attribute.datatype == "date"

				str_option = "attribute_" + attribute.id.to_s + "_option"
				str_date1 = "attribute_" + attribute.id.to_s + "_date1"
				str_date2 = "attribute_" + attribute.id.to_s + "_date2"
				str_exclusive1 = "attribute_" + attribute.id.to_s + "_exclusive1"
				str_exclusive2 = "attribute_" + attribute.id.to_s + "_exclusive2"

				if !params.keys.include?(str_date1)
					next
				end

				param_option = params[str_option]
				param_date1 = params[str_date1].to_date

				param_date2 = nil

				if !params[str_date2].blank?
					param_date2 = params[str_date2].to_date
				end

				param_exclusive1 = params[str_exclusive1].to_i
				param_exclusive2 = params[str_exclusive2].to_i

				if param_exclusive1 == 0
					param_exclusive1 = true
				else
					param_exclusive1 = false
				end

				if param_exclusive2 == 0
					param_exclusive2 = true
				else
					param_exclusive2 = false
				end

				date_filter = DateCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first
				if date_filter.nil?
					date_filter = DateCustomFilter.create(custom_filter_id: self.id, attribute_id: attribute.id, option: param_option, date1: param_date1, date2: param_date2, exclusive1: param_exclusive1, exclusive2: param_exclusive2)
				else
					date_filter.option = param_option
					date_filter.date1 = param_date1
					date_filter.date2 = param_date2
					date_filter.exclusive1 = param_exclusive1
					date_filter.exclusive2 = param_exclusive2
					date_filter.save
				end
			
			elsif attribute.datatype == "datetime"

				str_option = "attribute_" + attribute.id.to_s + "_option"
				str_date1 = "attribute_" + attribute.id.to_s + "_date1"
				str_date1_hour = "attribute_" + attribute.id.to_s + "_date1_hour"
				str_date1_minute = "attribute_" + attribute.id.to_s + "_date1_minute"
				str_date2 = "attribute_" + attribute.id.to_s + "_date2"
				str_date2_hour = "attribute_" + attribute.id.to_s + "_date2_hour"
				str_date2_minute = "attribute_" + attribute.id.to_s + "_date2_minute"
				str_exclusive1 = "attribute_" + attribute.id.to_s + "_exclusive1"
				str_exclusive2 = "attribute_" + attribute.id.to_s + "_exclusive2"

				if !params.keys.include?(str_date1)
					next
				end

				param_option = params[str_option]
				aux_date1 = params[str_date1].to_datetime
				param_date1 = DateTime.new(aux_date1.year, aux_date1.month, aux_date1.day, params[str_date1_hour].to_i, params[str_date1_minute].to_i, 0)

				param_date2 = nil

				if !params[str_date2].blank?
					aux_date2 = params[str_date2].to_datetime
					param_date2 = DateTime.new(aux_date2.year, aux_date2.month, aux_date2.day, params[str_date2_hour].to_i, params[str_date2_minute].to_i, 0)
				end

				param_exclusive1 = params[str_exclusive1].to_i
				param_exclusive2 = params[str_exclusive2].to_i

				if param_exclusive1 == 0
					param_exclusive1 = true
				else
					param_exclusive1 = false
				end

				if param_exclusive2 == 0
					param_exclusive2 = true
				else
					param_exclusive2 = false
				end

				date_filter = DateCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first
				if date_filter.nil?
					date_filter = DateCustomFilter.create(custom_filter_id: self.id, attribute_id: attribute.id, option: param_option, date1: param_date1, date2: param_date2, exclusive1: param_exclusive1, exclusive2: param_exclusive2)
				else
					date_filter.option = param_option
					date_filter.date1 = param_date1
					date_filter.date2 = param_date2
					date_filter.exclusive1 = param_exclusive1
					date_filter.exclusive2 = param_exclusive2
					date_filter.save
				end

			elsif attribute.datatype == "categoric"

				str_categories_ids = "attribute_" + attribute.id.to_s + "_multi_select"

				if !params.keys.include?(str_categories_ids)
					next
				end

				param_categories_ids = params[str_categories_ids].join(",")

				categoric_filter = CategoricCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first
				if categoric_filter.nil?
					categoric_filter = CategoricCustomFilter.create(custom_filter_id: self.id, attribute_id: attribute.id, categories_ids: param_categories_ids)
				else
					categoric_filter.categories_ids = param_categories_ids
					categoric_filter.save
				end
			elsif attribute.datatype == "text" || attribute.datatype == "textarea"
				str_text = "attribute_" + attribute.id.to_s + "_text"
				if !params.keys.include?(str_text) || params[str_text] == ""
					next
				end

				param_text = params[str_text]

				text_filter = TextCustomFilter.where(custom_filter_id: self.id, attribute_id: attribute.id).first
				if text_filter.nil?
					text_filter = TextCustomFilter.create(custom_filter_id: self.id, attribute_id: attribute.id, text: param_text)
				else
					text_filter.text = param_text
					text_filter.save
				end

			end

		end

	end

end
