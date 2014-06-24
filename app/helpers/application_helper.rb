module ApplicationHelper

	def root_without_subdomain
		root_url(:subdomain => false)
	end

end
