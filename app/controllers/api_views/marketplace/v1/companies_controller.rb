module ApiViews
  module Marketplace
	module V1
	  class CompaniesController < V1Controller
	  	def preview
	  		@companies =  Company.where(show_in_home: true, country_id: params[:country_id]).where.not(logo: nil)
	  	end
	  end
	end
  end
end