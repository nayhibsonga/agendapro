class ServiceProvidersController < ApplicationController
  before_action :set_service_provider, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!, except: [:location_services, :location_providers, :provider_time, :available_hours_week_html]
  before_action :quick_add, except: [:location_services, :location_providers, :provider_time, :available_hours_week_html]
  load_and_authorize_resource
  layout "admin", except: [:location_services, :location_providers, :provider_time, :available_hours_week_html]

  # GET /service_providers
  # GET /service_providers.json
  def index
    @locations = Location.where(company_id: current_user.company_id, :active => true).order(:order, :name).accessible_by(current_ability)
    @service_providers = ServiceProvider.where(company_id: current_user.company_id, :active => true).accessible_by(current_ability).order(:order, :public_name)
  end

  def inactive_index
    @service_providers = ServiceProvider.where(company_id: current_user.company_id, :active => false).accessible_by(current_ability).order(:order, :public_name)
  end

  def activate
    @service_provider.active = true
    @service_provider.save
    redirect_to inactive_service_providers_path
  end

  def deactivate
    @service_provider.active = false
    @service_provider.save
    redirect_to service_providers_path
  end

  # GET /service_providers/1
  # GET /service_providers/1.json
  def show
  end

  def pdf
    if params[:service_provider_id] != "0"
      @filename = ServiceProvider.find(params[:service_provider_id]).public_name
    else
      @filename = Location.find(params[:location_id]).name
    end
    if params[:provider_date ] && params[:provider_date] != ""
      date = DateTime.parse(params[:provider_date])
    else
      date = DateTime.now
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ServiceProvidersPdf.new(params[:service_provider_id].to_i, date, params[:location_id].to_i, current_ability)
        send_data pdf.render, filename: @filename + "_" + date.to_s[0,10] + '.pdf', type: 'application/pdf'
      end
    end
  end

  # GET /service_providers/new
  def new
    @service_provider = ServiceProvider.new
    @service_provider.company_id = current_user.company_id
    # @users = User.where(company_id: current_user.company_id)
    # @locations = Location.where(company_id: current_user.company_id)
    @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(:order, :name)
  end

  # GET /service_providers/1/edit
  def edit
    @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(:order, :name)
  end

  # POST /service_providers
  # POST /service_providers.json
  def create

    @service_provider = ServiceProvider.new(service_provider_params)
    @service_provider.company_id = current_user.company_id

    respond_to do |format|
      if @service_provider.save
        flash[:notice] = 'Prestador creado exitosamente.'
        format.html { redirect_to service_providers_path }
        format.json { render :json => @service_provider }
      else
        format.html { render action: 'new' }
        format.json { render :json => { :errors => @service_provider.errors.full_messages }, :status => 422 }
      end
    end
  end

  # PATCH/PUT /service_providers/1
  # PATCH/PUT /service_providers/1.json
  def update
    @provider_times = ServiceProvider.find(params[:id]).provider_times
    @provider_times.each do |provider_time|
      provider_time.service_provider_id = nil
      provider_time.save
    end
    @service_provider = ServiceProvider.find(params[:id])
    if !service_provider_params[:service_ids].present?
      @service_provider.services.delete_all
    end
    respond_to do |format|
      if @service_provider.update(service_provider_params)
        @provider_times.destroy_all
        flash[:notice] = 'Prestador actualizado exitosamente.'
        format.html { redirect_to service_providers_path }
        format.json { render :json => @service_provider }
      else
        @provider_times.each do |provider_time|
          provider_time.service_provider_id = @service_provider.id
          provider_time.save
        end
        format.html { render action: 'edit' }
        format.json { render :json => { :errors => @service_provider.errors.full_messages }, :status => 422 }
      end
    end
  end

  # DELETE /service_providers/1
  # DELETE /service_providers/1.json
  def destroy
    @service_provider.destroy
    respond_to do |format|
      format.html { redirect_to service_providers_url }
      format.json { head :no_content }
    end
  end

  def location_providers
    render :json => ServiceProvider.where(:active => true).where('location_id = ?', params[:location]).accessible_by(current_ability).order(:order, :public_name)
  end

  def provider_time
    provider_time = ServiceProvider.find(params[:id]).provider_times.order(:day_id, :open)
    render :json => provider_time
  end

  def provider_service
    provider = ServiceProvider.find(params[:id])
    services = provider.services.where(:active => true).order(:order, :name)
    bundles = Bundle.where(id: ServiceBundle.where(service_id: services.pluck(:id)).pluck(:bundle_id))
    services_array = Array.new
    services.each do |service|
      serviceJSON = service.attributes.merge({'name_with_small_outcall' => service.name_with_small_outcall, 'bundle' => false })
      services_array.push(serviceJSON)
    end
    if params[:bundle] == "true"
      bundles.each do |bundle|
        bundleJSON = bundle.attributes.merge({'name_with_small_outcall' => bundle.name, 'bundle' => true, 'duration' => bundle.services.sum(:duration) })
        services_array.push(bundleJSON)
      end
    end
    render :json => services_array
  end

  def available_providers
    location = Location.find(params[:location_id])
    service_providers = []
    ServiceProvider.where(location_id: location.id).each do |service_provider|
      available = true
      service_provider.bookings.each do |booking|
        if (booking.start - Date(params[:end])) * (Date(params[:start]) - booking.end) > 0
          if !booking.is_session || (booking.is_session && booking.is_session_booked)
            available = false
          end
        end
      end
      if available
        service_providers.push(service_provider.id)
      end
    end
    render :json => service_providers
  end

  def change_providers_order
    array_result = Array.new
    params[:providers_order].each do |pos, provider_hash|
      provider = ServiceProvider.find(provider_hash[:provider])
      if provider.update(:order => provider_hash[:order])
        array_result.push({
          provider: provider.public_name,
          status: 'Ok'
        })
      else
        array_result.push({
          provider: provider.public_name,
          status: 'Error',
          errors: provider.errors
        })
      end
    end
    render :json => array_result
  end

  def available_hours_week_html
    if !params[:provider].blank? && !params[:service].blank? && !params[:local].blank? && !params[:date].blank?
      render :json => ServiceProvider.available_hours_week_html(params[:provider], params[:service], params[:local], params[:date])
    else
      render :json => ''
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_provider
      @service_provider = ServiceProvider.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_provider_params
      params.require(:service_provider).permit(:user_id, :location_id, :public_name, :block_length, :online_booking, :service_ids => [], provider_times_attributes: [:id, :open, :close, :day_id, :service_provider_id, :_destroy], user_attributes: [:email, :password, :confirm_password, :role_id, :company_id, :location_id])
    end
end
