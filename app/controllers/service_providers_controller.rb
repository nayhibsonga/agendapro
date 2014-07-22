class ServiceProvidersController < ApplicationController
  before_action :set_service_provider, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!, except: [:location_services, :location_providers, :provider_time]
  before_action :quick_add, except: [:location_services, :location_providers, :provider_time]
  load_and_authorize_resource
  layout "admin", except: [:location_services, :location_providers, :provider_time]

  # GET /service_providers
  # GET /service_providers.json
  def index
    @locations = Location.where(company_id: current_user.company_id, :active => true).order(order: :asc).accessible_by(current_ability)
    @service_providers = ServiceProvider.where(company_id: current_user.company_id, :active => true).accessible_by(current_ability).order(:order)
  end

  def inactive_index
    @service_providers = ServiceProvider.where(company_id: current_user.company_id, :active => false).accessible_by(current_ability)
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

  # GET /service_providers/new
  def new
    @service_provider = ServiceProvider.new
    @service_provider.company_id = current_user.company_id
    # @users = User.where(company_id: current_user.company_id)
    # @locations = Location.where(company_id: current_user.company_id)
    @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(name: :asc)
  end

  # GET /service_providers/1/edit
  def edit
    @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(name: :asc)
  end

  # POST /service_providers
  # POST /service_providers.json
  def create

    @service_provider = ServiceProvider.new(service_provider_params)
    @service_provider.company_id = current_user.company_id

    respond_to do |format|
      if @service_provider.save
        format.html { redirect_to service_providers_path, notice: 'Prestador creado satisfactoriamente.' }
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
    @service_provider.provider_times.destroy_all
    respond_to do |format|
      if @service_provider.update(service_provider_params)
        format.html { redirect_to service_providers_path, notice: 'Prestador actualizado satisfactoriamente.' }
        format.json { render :json => @service_provider }
      else 
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
    render :json => ServiceProvider.where(:active => true).where('location_id = ?', params[:location]).accessible_by(current_ability).order(:order)
  end

  def provider_time
    provider_time = ServiceProvider.find(params[:id]).provider_times
    render :json => provider_time
  end

  def provider_service
    provider = ServiceProvider.find(params[:id])
    services = provider.services.where(:active => true).order(:name)
    render :json => services
  end

  def available_providers
    location = Location.find(params[:location_id])
    service_providers = []
    ServiceProvider.where(location_id: location.id).each do |service_provider|
      available = true
      service_provider.bookings.each do |booking|
        if (booking.start - Date(params[:end])) * (Date(params[:start]) - booking.end) > 0
          available = false
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_provider
      @service_provider = ServiceProvider.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_provider_params
      params.require(:service_provider).permit(:user_id, :location_id, :public_name, :notification_email, :service_ids => [], provider_times_attributes: [:id, :open, :close, :day_id, :service_provider_id, :_destroy], user_attributes: [:email, :password, :confirm_password, :role_id, :company_id, :location_id])
    end
end
