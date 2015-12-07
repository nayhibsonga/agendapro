module ApiViews
  module Marketplace
	module V1
	  class EconomicSectorsController < V1Controller
	  	def index
	  		@economic_sectors = EconomicSector.where(marketplace: true)
	  	end

	  	def categories
	  		@categories = MarketplaceCategory.where(show_in_marketplace: true).order(:id)
		end
	  end
	end
  end
end