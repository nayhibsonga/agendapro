class ReportsController < ApplicationController

	before_action :authenticate_user!
	before_action :verify_is_admin
	before_action :quick_add
	layout "admin"

	def index
		@locations = Location.accessible_by(current_ability).where(active: true).order(:name)
	end

	def statuses
		render "_statuses", layout: false
	end

	def status_details
		status_id = params[:status_id].to_i
		time_range_id = params[:time_range_id].to_i

		render "_status_details", layout: false
	end

	def locations
	  	render "_locations", layout: false
	end

	def services
		@services = Service.where(company_id: current_user.company_id, active: true)

	  	render "_services", layout: false
	end

	def location_providers
		@location = Location.find(params[:id])

	  	render "_location_providers", layout: false
	end

	def location_comission
		@location = Location.find(params[:id])

	  	render "_location_comission", layout: false
	end

	def location_services
		@location = Location.find(params[:id])
		@services = Service.where(id: ServiceStaff.where(service_provider_id: @location.service_providers.where(active: true).pluck(:id)).pluck(:service_id), active: true)

	  	render "_location_services", layout: false
	end
	
	def provider_services
		@service_provider = ServiceProvider.find(params[:id])

	  	render "_provider_services", layout: false
	end
end
