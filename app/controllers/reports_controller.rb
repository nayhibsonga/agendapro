class ReportsController < ApplicationController

	before_action :authenticate_user!
	before_action :quick_add
	layout "admin"

	def index
		@locations = Location.accessible_by(current_ability).where(active: true).order(:name)
	end

	def locations
	  	render "_locations", layout: false
	end

	def services
	  	render "_services", layout: false
	end

	def location_providers
		if params[:id] != 0
			@location = Location.find(params[:id])
		else
			@location = Location.where(company_id: current_user.company_id).order(:name).first
		end
	  	render "_location_providers", layout: false
	end

	def location_services
		if params[:id] != 0
			@location = Location.find(params[:id])
		else
			@location = Location.where(company_id: current_user.company_id).order(:name).first
		end
	  	render "_location_services", layout: false
	end
	
	def provider_services
		if params[:id] != 0
			@service_provider = ServiceProvider.find(params[:id])
		else
			@service_provider = ServiceProvider.where(company_id: current_user.company_id).order(:public_name).first
		end
	  	render "_provider_services", layout: false
	end
end
