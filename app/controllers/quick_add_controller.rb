class QuickAddController < ApplicationController

	before_action :authenticate_user!
	layout "quick_add"

	def location
		@location = Location.new
		@location.company_id = current_user.company_id
	end

	def services
		@service = Service.new
	    @service.company_id = current_user.company_id
	end

	def service_provider
		@service_provider = ServiceProvider.new
		@service_provider.company_id = current_user.company_id
	end

	def create_location
		@location = Location.new(location_params)
	    @location.company_id = current_user.company_id

	    respond_to do |format|
	      if @location.save
	        format.html { redirect_to quick_add_services_path, notice: 'Local creado satisfactoriamente.' }
        	format.json { render :json => @location }
	      else
	        format.html { render action: 'location' }
	        format.json { render :json => { :errors => @location.errors.full_messages }, :status => 422 }
	      end
	    end
	end

  	def create_services
	    @service = Service.new(service_params)
	    @service.company_id = current_user.company_id

	    respond_to do |format|
	      if @service.save
	        format.html { redirect_to quick_add_service_provider_path, notice: 'Servicio creado satisfactoriamente.' }
	      else
	        format.html { render action: 'services' }
	      end
	    end
  	end

	def create_service_provider
	    @service_provider = ServiceProvider.new(service_provider_params)
	    @service_provider.company_id = current_user.company_id

	    respond_to do |format|
	      if @service_provider.save
	        format.html { redirect_to dashboard_path, notice: 'Proveedor creado satisfactoriamente.' }
        	format.json { render :json => @service_provider }
	      else
	        format.html { render action: 'service_provider' }
        	format.json { render :json => { :errors => @service_provider.errors.full_messages }, :status => 422 }
	      end
	    end
  	end

  	def location_params
      params.require(:location).permit(:name, :address, :phone, :longitude, :latitude, :company_id, :district_id, location_times_attributes: [:id, :open, :close, :day_id, :location_id, :_destroy])
    end

    def service_provider_params
      params.require(:service_provider).permit(:user_id, :location_id, :public_name, :notification_email, :service_ids => [], provider_times_attributes: [:id, :open, :close, :day_id, :service_provider_id, :_destroy])
    end

    def service_params
      params.require(:service).permit(:name, :price, :duration, :description, :group_service, :capacity, :waiting_list, :company_id, :tag_id, :service_category_id)
    end
end
