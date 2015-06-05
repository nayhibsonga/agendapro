class QuickAddController < ApplicationController

	before_action :authenticate_user!
	layout "quick_add", only: [:quick_add]
	before_action :quick_add_filter

	def quick_add_filter
		if current_user && (current_user.role_id != Role.find_by_name("Super Admin").id) && current_user.company_id
			@company = Company.find(current_user.company_id)
			if @company.economic_sectors.count == 0
				return
			elsif @company.locations.count == 0
				params[:step] = 1
			elsif @company.services.count == 0
				params[:step] = 2
			elsif @company.service_providers.count == 0
				params[:step] = 3
			end
		end
	end

	def quick_add
		if ServiceCategory.where(company_id: current_user.company_id, name: "Otros").count < 1
	        @service_category = ServiceCategory.new(name: "Otros", company_id: current_user.company_id)
	        @service_category.save
    	end
    	if ResourceCategory.where(company_id: current_user.company_id, name: "Otros").count < 1
	        @resource_category = ResourceCategory.new(name: "Otros", company_id: current_user.company_id)
	        @resource_category.save
    	end
		@location = Location.new
		@service_category = ServiceCategory.new
		@service = Service.new
		@service_provider = ServiceProvider.new

		@location.company_id = current_user.company_id
		@service.company_id = current_user.company_id
		@service_provider.company_id = current_user.company_id

		@company = current_user.company
		@company_setting = @company.company_setting
		@company_setting.build_online_cancelation_policy
		@company_setting.save
	end

	def load_location
		@location = Location.find(params[:id])
		render json: {location: @location, location_times: @location.location_times, location_districts: @location.location_outcall_districts, country_id: @location.district.city.region.country.id, region_id: @location.district.city.region.id, city_id: @location.district.city.id}
	end

	# def location_valid
	# 	@location = Location.new(location_params)
	#     @location.company_id = current_user.company_id

	#     respond_to do |format|
	#       if @location.valid?
	#         format.json { render :layout => false, :json => {:valid => true} }
	#       else
	#         format.json { render :layout => false, :json => { :valid => false, :errors => @location.errors.full_messages } }
	#       end
	#     end
	# end

	# def services_valid
	# 	if service_params[:service_category_attributes]
	# 		if service_params[:service_category_attributes][:name].nil?
	#         	new_params = service_params.except(:service_category_attributes)
	#     	else
	#         	new_params = service_params.except(:service_category_id)
	#     	end
	#     end
	#     @service = Service.new(new_params)
	#     @service.company_id = current_user.company_id

	#     respond_to do |format|
	#       if @service.valid?
	#         format.json { render :layout => false, :json => {:valid => true} }
	#       else
	#         format.json { render :layout => false, :json => {:valid => false, :errors => @service.errors.full_messages} }
	#       end
	#     end
	# end

	# def service_provider_valid
	# 	@service_provider = ServiceProvider.new(service_provider_params)
	#     @service_provider.company_id = current_user.company_id

	#     respond_to do |format|
	#       if @service_provider.valid?
 #        	format.json { render :layout => false, :json => {:valid => true} }
	#       else
	#         format.json { render :layout => false, :json => { :valid => false, :errors => @service_provider.errors.full_messages }, :status => 422 }
	#       end
	#     end
	# end

  	def update_company
  		puts company_params[:economic_sector_ids]
  		if company_params[:economic_sector_ids] == [""]
  			render :json => { :errors => ['Debes elegir al menos un rubro o sector económico.'] }, :status => 422
  			return
  		end
  		respond_to do |format|
			if @company.update(company_params)
				format.json { render :layout => false, :json => @company.logo_url }
			else
				format.json { render :layout => false, :json => { :errors => @company.errors.full_messages }, :status => 422 }
			end
		end
  	end

	def create_location
		@location = Location.new(location_params)
	    @location.company_id = current_user.company_id

	    if location_params[:location_times_attributes].blank? || location_params[:location_times_attributes] == [""]
  			render :json => { :errors => ['Debes elegir un horario con al menos un día disponible.'], :location_count => @location.company.locations.where(active: true).count }, :status => 422
  			return
  		end

	    respond_to do |format|
	      if @location.save
	        format.json { render :layout => false, :json => @location }
	      else
	        format.json { render :layout => false, :json => { :errors => @location.errors.full_messages, :location_count => @location.company.locations.where(active: true).count }, :status => 422 }
	      end
	    end
	end
	def update_location
		@location = Location.find(params[:id])
		@location_times = @location.location_times
		if location_params[:location_times_attributes].blank? || location_params[:location_times_attributes] == [""]
  			render :json => { :errors => ['Debes elegir un horario con al menos un día disponible.'], :location_count => @location.company.locations.where(active: true).count }, :status => 422
  			return
  		end
	    @location_times.each do |location_time|
	      location_time.location_id = nil
	      location_time.save
	    end
	    respond_to do |format|
	      if @location.update(location_params)
        	@location_times.destroy_all
	        format.json { render :layout => false, :json => @location }
	      else
	        @location_times.each do |location_time|
	          location_time.location_id = @location.id
	          location_time.save
	        end
	        format.json { render :layout => false, :json => { :errors => @location.errors.full_messages, :location_count => @location.company.locations.where(active: true).count }, :status => 422 }
	      end
	    end
	end

	def create_service_category
	    @service_category = ServiceCategory.new(service_category_params)
	    @service_category.company_id = current_user.company_id

	    respond_to do |format|
	      if @service_category.save
	        format.json { render :layout => false, :json => @service_category }
	      else
	        format.json { render :layout => false, :json => { :errors => @service_category.errors.full_messages, :status => 422} }
	      end
	    end
  	end
  	def delete_service_category
  		@service_category = ServiceCategory.find(params[:id])
  		if @service_category.name == "Otros"
			render :json => { :errors => ['No se puede eliminar esta categoría.']} , :status => 422
			return
		end
		@services = Service.where(service_category_id: @service_category)
		@new_service_category = ServiceCategory.where(company_id: @service_category.company_id, name: "Otros").first
		if @new_service_category.nil?
			@new_service_category = ServiceCategory.create(name: "Otros", company_id: @service_category.company_id)
			@new_service_category.save
		end
	    @services.each do |service|
	      service.service_category = @new_service_category
	      service.save
	    end
	    respond_to do |format|
	      if @service_category.destroy
	        format.json { render :layout => false, :json => @service_category }
	      else
	        format.json { render :layout => false, :json => { :errors => @service_category.errors.full_messages, :status => 422} }
	      end
	    end
  	end

  	def create_service
	    @service = Service.new(service_params)
	    @service.company_id = current_user.company_id

	    respond_to do |format|
	      if @service.save
	        format.json { render :layout => false, :json => { service: @service, service_category: @service.service_category.name } }
	      else
	        format.json { render :layout => false, :json => { :errors => @service.errors.full_messages }, :status => 422 }
	      end
	    end
  	end
  	def delete_service
	    @service = Service.find(params[:id])

	    respond_to do |format|
	      if @service.update(active: false)
	        format.json { render :layout => false, :json => { service: @service, service_count: @service.company.services.where(active:true).count } }
	      else
	        format.json { render :layout => false, :json => { :errors => @service.errors.full_messages }, :status => 422 }
	      end
	    end
  	end

	def create_service_provider
	    @service_provider = ServiceProvider.new(service_provider_params)
	    @service_provider.company_id = current_user.company_id

	    if Location.find(service_provider_params[:location_id]).outcall
	    	Service.where(company_id: current_user.company_id, active: true).each do |service|
	    		service.outcall = true
	    		service.save
	    	end
	    end

	    @service_provider.services = Service.where(company_id: current_user.company_id, active: true)

	    @provider_times = []
	    Location.find(service_provider_params[:location_id]).location_times.each do |location_time|
	    	@provider_times.push(ProviderTime.new(day_id: location_time.day_id, open:location_time.open, close: location_time.close))
	    end
	    @service_provider.provider_times = @provider_times

	    respond_to do |format|
	      if @service_provider.save
	        format.json { render :layout => false, :json => { service_provider: @service_provider, location: @service_provider.location.name } }
	      else
	        format.json { render :layout => false, :json => { :errors => @service_provider.errors.full_messages }, :status => 422 }
	      end
	    end
  	end
  	def delete_service_provider
  		@service_provider = ServiceProvider.find(params[:id])
	    respond_to do |format|
	      if @service_provider.update(active: false)
	        format.json { render :layout => false, :json => { service_provider: @service_provider, service_provider_count: @service_provider.company.service_providers.where(active: true).count } }
	      else
	        format.json { render :layout => false, :json => { :errors => @service_provider.errors.full_messages }, :status => 422 }
	      end
	    end
  	end

  # 	def update_settings
  # 		respond_to do |format|
  # 			@company_setting = @company.company_setting
		# 	if @company_setting.update(company_setting_params)
		# 		format.json { head :no_content }
		# 	else
		# 		format.json { render :layout => false, :json => { :errors => @company_setting.errors.full_messages }, :status => 422 }
		# 	end
		# end
  # 	end

  	def location_params
      params.require(:location).permit(:name, :address, :second_address, :phone, :longitude, :latitude, :company_id, :district_id, :outcall, :district_ids => [], location_times_attributes: [:id, :open, :close, :day_id, :location_id, :_destroy])
    end

    def service_provider_params
      params.require(:service_provider).permit(:user_id, :location_id, :public_name, :notification_email, :service_ids => [], provider_times_attributes: [:id, :open, :close, :day_id, :service_provider_id, :_destroy])
    end

    def service_category_params
      params.require(:service_category).permit(:name)
    end

    def service_params
      params.require(:service).permit(:name, :price, :duration, :description, :group_service, :capacity, :waiting_list, :company_id, :service_category_id, :outcall, :online_payable, :has_discount, :discount, service_category_attributes: [:name, :company_id],  :tag_ids => [] )
    end

    def company_params
    	params.require(:company).permit(:logo, :description, :allows_online_payment, :bank, :account_number, :company_rut, economic_sector_ids: [])
    end

    # def company_setting_params
    #   params.require(:company_setting).permit(:email, :sms, :signature, :company_id, :before_booking, :after_booking, :before_edit_booking, :activate_workflow, :activate_search, :client_exclusive, :provider_preference, :calendar_duration, :extended_schedule_bool, :extended_min_hour, :extended_max_hour, :schedule_overcapacity, :provider_overcapacity, :resource_overcapacity, :booking_confirmation_time, :page_id, :max_changes, :booking_history, :staff_code, :booking_configuration_email, :allows_online_payment, :bank_id, :account_number, :company_rut, :account_name, :account_type, online_cancelation_policy_attributes: [:cancelable, :cancel_max, :cancel_unit, :min_hours, :modifiable, :modification_max, :modification_unit])
    # end

end
