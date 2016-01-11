module Api
  module Horachic
  module V1
  	class ServicesController < V1Controller
      before_action :check_service_providers_params, only: [:service_providers]
      
      def show
        @service = Service.find(params[:id])
      end

      def service_providers
        @service = Service.find(params[:id])
        @service_providers = @service.service_providers.where(:active => true, online_booking: true).where('location_id = ?', params[:location_id]).order(order: :asc)
      end

      private

      def check_service_providers_params
        if !params[:location_id].present?
          render json: { error: 'Invalid User. Param(s) missing.' }, status: 500
        end
      end
  	end
  end
end
end