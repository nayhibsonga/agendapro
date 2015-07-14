module Api
  module V1
  	class LocationsController < V1Controller
      def index
      	@locations = Location.where(active: true, online_booking: true).last(20)
      end
  	end
  end
end