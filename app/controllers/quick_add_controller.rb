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
    if CompanyCountry.where(company_id: current_user.company_id).count < 1
      @company_country = CompanyCountry.new(company_id: current_user.company_id, country_id: current_user.company.country_id, web_address: current_user.company.web_address)
      @company_country.save
    end

    @referer = params[:referer]

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

    if @referer == "horachic"
      @company_setting.before_booking = 2
      @company_setting.after_booking = 2
      if @company.description.nil? || @company.description == "" || @company.logo.nil?
        params[:step] = 0
      end
    end

    @company_setting.save

    @notification_email = NotificationEmail.new
    @notifications = NotificationEmail.where(company: @company).order(:receptor_type)
  end

  def update_company
    puts company_params[:economic_sector_ids]
    if company_params[:economic_sector_ids] == [""]
      render :json => { :errors => ['Debes elegir al menos un rubro o sector económico.'] }, :status => 422
      return
    end
    respond_to do |format|
      if @company.update(company_params)
        format.json { render :layout => false, :json => @company.logo.thumb.url }
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
    if location_params[:location_times_attributes].blank? || location_params[:location_times_attributes] == [""]
      render :json => { :errors => ['Debes elegir un horario con al menos un día disponible.'], :location_count => @location.company.locations.where(active: true).count }, :status => 422
      return
    end
    @location_times = @location.location_times
    @location_time_ids = @location_times.pluck(:id)
    @location_times.each do |location_time|
      location_time.location_id = nil
      location_time.save
    end
    @location = Location.find(params[:id])
    respond_to do |format|
      if @location.update(location_params)
        LocationTime.where(id: @location_time_ids).destroy_all
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

  def load_location
    @location = Location.find(params[:id])
    render json: {location: @location, location_times: @location.location_times, location_districts: @location.location_outcall_districts, country_id: @location.district.city.region.country.id, region_id: @location.district.city.region.id, city_id: @location.district.city.id}
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

  def list_services
    services = Service.where(company_id: current_user.company_id).actives
    @services = Array.new
    services.each do |service|
      @services << {
        service: service.as_json,
        service_category: service.service_category.name
      }
    end
    render json: @services
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

  def save_configurations
    @company_setting = CompanySetting.find(params[:id])
    respond_to do |format|
      if @company_setting.update(company_setting_params)
        format.json { render :layout => false, :json => { :status => "ok" } }
      else
        format.json { render :layout => false, :json => { :status => "error", :errors => @company_setting.errors.full_messages }, :status => 422 }
      end
    end
  end

  def create_notification_email
    @notification_email = NotificationEmail.new(notification_email_params)
    respond_to do |format|
      if @notification_email.save
        @notification_email_hash = @notification_email.attributes.to_options
        @notification_email_hash[:receptor_type_text] = @notification_email.receptor_type_text
        @notification_email_hash[:notification_text] = @notification_email.notification_text
        format.json { render :layout => false, :json => { :notification_email => @notification_email_hash } }
      else
        format.json { render :layout => false, :json => { :errors => @notification_email.errors.full_messages }, :status => 422 }
      end
    end
  end

  def delete_notification_email
    @notification_email = NotificationEmail.find(params[:id])
    respond_to do |format|
      if @notification_email.destroy
        format.json { render :layout => false, :json => { :status => "ok" } }
      else
        format.json { render :layout => false, :json => { :status => "error", :errors => @notification_email.errors.full_messages }, :status => 422 }
      end
    end
  end

  def company_params
    params.require(:company).permit(:logo, :description, :allows_online_payment, :bank, :account_number, :company_rut, economic_sector_ids: [])
  end

  def location_params
    params.require(:location).permit(:name, :address, :second_address, :phone, :longitude, :latitude, :company_id, :district_id, :outcall, :email, :district_ids => [], location_times_attributes: [:id, :open, :close, :day_id, :location_id, :_destroy])
  end

  def service_category_params
    params.require(:service_category).permit(:name)
  end

  def service_params
    params.require(:service).permit(:name, :price, :duration, :description, :group_service, :capacity, :waiting_list, :company_id, :service_category_id, :outcall, :online_payable, :has_discount, :discount, :has_sessions, :sessions_amount, service_category_attributes: [:name, :company_id],  :tag_ids => [] )
  end

  def service_provider_params
    params.require(:service_provider).permit(:user_id, :location_id, :public_name, :notification_email, :service_ids => [], provider_times_attributes: [:id, :open, :close, :day_id, :service_provider_id, :_destroy])
  end

  def company_setting_params
    params.require(:company_setting).permit(:before_booking, :after_booking, :booking_confirmation_time, :can_edit, :can_cancel)
  end

  def notification_email_params
    params.require(:notification_email).permit(:company_id, :email, :notification_type, :receptor_type, :summary, :new, :modified, :confirmed, :canceled, :new_web, :modified_web, :confirmed_web, :canceled_web, location_ids: [], service_provider_ids: [])
  end

end
