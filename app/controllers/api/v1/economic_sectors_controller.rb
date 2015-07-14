module Api
  module V1
  	class EconomicSectorsController < V1Controller
      def index
      	@economic_sectors = EconomicSector.where(show_in_home: true)
      end
  	end
  end
end