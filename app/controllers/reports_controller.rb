class ReportsController < ApplicationController

	before_action :authenticate_user!
	before_action :verify_is_admin
	before_action :quick_add
	before_action :set_params
	layout "admin"

	def index
		@locations = Location.accessible_by(current_ability).where(company_id: current_user.company_id, active: true).order(:name)
	end

	def statuses
		render "_statuses", layout: false
	end

	def status_details
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

	def set_params
		params[:from] ||= Time.now.strftime("%Y-%m-%d")
		params[:to] ||= Time.now.strftime("%Y-%m-%d")
		params[:status] ||= 0
		params[:option] ||= 0
	end
end
