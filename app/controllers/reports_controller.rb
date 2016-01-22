class ReportsController < ApplicationController

	before_action :authenticate_user!
	before_action :verify_is_admin
	before_action :quick_add
	before_action -> (source = "reports") { verify_free_plan source }
	before_action :set_params
	layout "admin"

	def index
		@locations = Location.accessible_by(current_ability).where(company_id: current_user.company_id, active: true).order(:order, :name)
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
		@from = params[:from].blank? ? Time.now.beginning_of_day : Time.parse(params[:from]).beginning_of_day
		@to = params[:to].blank? ? Time.now.end_of_day : Time.parse(params[:to]).end_of_day
		@status_ids = params[:status_ids] ? Status.where(id: params[:status_ids].split(',').map { |i| i.to_i }) : Status.where.not(name: 'Cancelado').pluck(:id)
		puts @status_ids
		@option = params[:option] ? params[:option].to_i : 0
	end
end
