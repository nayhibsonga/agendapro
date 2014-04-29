class QuickAddController < ApplicationController

	before_action :authenticate_user!
	layout "quick_add", only: [:quick_add]

	def quick_add
		if ServiceCategory.where(company_id: current_user.company_id).count < 1
	        @service_category = ServiceCategory.new(name: "Sin Categoría", company_id: current_user.company_id)
	        @service_category.save
    	end
		@location = Location.new
		@service = Service.new
		@service_provider = ServiceProvider.new

		@location.company_id = current_user.company_id
		@service.company_id = current_user.company_id
		@service_provider.company_id = current_user.company_id
	end

	def location_valid
		@location = Location.new(location_params)
	    @location.company_id = current_user.company_id

	    respond_to do |format|
	      if @location.valid?
	        format.json { render :layout => false, :json => {:valid => true} }
	      else
	        format.json { render :layout => false, :json => { :valid => false, :errors => @location.errors.full_messages } }
	      end
	    end
	end

	def services_valid
		if service_params[:service_category_attributes][:name].nil?
	      new_params = service_params.except(:service_category_attributes)
	    else
	      new_params = service_params
	    end
	    @service = Service.new(new_params)
	    @service.company_id = current_user.company_id

	    respond_to do |format|
	      if @service.valid?
	        format.json { render :layout => false, :json => {:valid => true} }
	      else
	        format.json { render :layout => false, :json => {:valid => false, :errors => @service.errors.full_messages} }
	      end
	    end
	end

	def service_provider_valid
		@service_provider = ServiceProvider.new(service_provider_params)
	    @service_provider.company_id = current_user.company_id

	    respond_to do |format|
	      if @service_provider.valid?
        	format.json { render :layout => false, :json => {:valid => true} }
	      else
	        format.json { render :layout => false, :json => { :valid => false, :errors => @service_provider.errors.full_messages }, :status => 422 }
	      end
	    end
	end

	def create_location
		@location = Location.new(location_params)
	    @location.company_id = current_user.company_id

	    respond_to do |format|
	      if @location.save
	        format.json { render :layout => false, :json => @location }
	      else
	        format.json { render :layout => false, :json => { :errors => @location.errors.full_messages }, :status => 422 }
	      end
	    end
	end

  	def create_services
	    if service_params[:service_category_attributes]
	      if service_params[:service_category_attributes][:name] == ""
	        new_params = service_params.except(:service_category_attributes)
	      else
	        new_params = service_params.except(:service_category_id)
	      end
	    end
	    @service = Service.new(new_params)
	    @service.company_id = current_user.company_id

	    respond_to do |format|
	      if @service.save
	        format.json { render :layout => false, :json => @service }
	      else
	        format.json { render :layout => false, :json => { :errors => @service.errors.full_messages, :status => 422} }
	      end
	    end
  	end

	def create_service_provider
	    @service_provider = ServiceProvider.new(service_provider_params)
	    @service_provider.company_id = current_user.company_id

	    respond_to do |format|
	      if @service_provider.save
	      	@serviceStaff = ServiceStaff.new(:service_id => Service.find_by(:company_id => current_user.company_id).id, :service_provider_id => @service_provider.id)
	      	if @serviceStaff.save
	        	format.json { render :layout => false, :json => @service_provider }
	        else
	        	format.json { render :layout => false, :json => { :errors => @serviceStaff.errors.full_messages }, :status => 422 }
	        end
	      else
	        format.json { render :layout => false, :json => { :errors => @service_provider.errors.full_messages }, :status => 422 }
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
      params.require(:service).permit(:name, :price, :duration, :description, :group_service, :capacity, :waiting_list, :company_id, :service_category_id, service_category_attributes: [:name, :company_id],  :tag_ids => [] )
    end
end
