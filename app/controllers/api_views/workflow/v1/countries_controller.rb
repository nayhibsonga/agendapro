module ApiViews
  module Workflow
    module V1
      class CountriesController < V1Controller
  	  	def show
  	  		@country =  Country.find(params[:id])
  	  	end
      end
    end
  end
end
