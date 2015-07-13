module Api
  module V1
  	class LocationsController < ApiController
      def index
      	@locations = Location.where(active: true, online_booking: true).limit(20)
      end
  	end
  end
end