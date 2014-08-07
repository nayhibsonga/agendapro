module ApplicationHelper

	def int_with_variation(int, past_int)
		if past_int > 0
			variation = (int - past_int)/past_int.to_f
			if variation > 0
				variation_class = 'positive-variation'
				icon = 'fa-arrow-up'
			else
				variation_class = 'negative-variation'
				icon = 'fa-arrow-down'
			end
			return (int.to_s+' (<span class="'+variation_class+'"><i class="fa '+icon+'"></i></span> '+(100*variation.abs).round(2).to_s+' %)').html_safe
		else
			return int.to_s
		end
	end

	def float_with_variation(float, past_float)
		if past_float > 0
			variation = (float - past_float)/past_float
			if variation > 0
				variation_class = 'positive-variation'
				icon = 'fa-arrow-up'
			else
				variation_class = 'negative-variation'
				icon = 'fa-arrow-down'
			end
			return (float.round(2).to_s+' (<span class="'+variation_class+'"><i class="fa '+icon+'"></i></span> '+(100*variation.abs).round(2).to_s+' %)').html_safe
		else
			return float.round(2).to_s
		end
	end

	def root_without_subdomain
		root_url(:subdomain => false)
	end

end
