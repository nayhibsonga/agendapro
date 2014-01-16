class ServiceProvidersController < ApplicationController
  before_action :set_service_provider, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:location_services, :provider_time]
  before_action :quick_add, except: [:location_services, :provider_time]
  layout "admin", except: [:location_services, :provider_time]

  # GET /service_providers
  # GET /service_providers.json
  def index
    @service_providers = ServiceProvider.where(location_id: Location.where(company_id: current_user.company_id))
  end

  # GET /service_providers/1
  # GET /service_providers/1.json
  def show
  end

  # GET /service_providers/new
  def new
    @service_provider = ServiceProvider.new
    @service_provider.company_id = current_user.company_id
    #@users = User.where(company_id: current_user.company_id)
    #@locations = Location.where(company_id: current_user.company_id)
  end

  # GET /service_providers/1/edit
  def edit
  end

  # POST /service_providers
  # POST /service_providers.json
  def create
    @service_provider = ServiceProvider.new(service_provider_params)
    @service_provider.company_id = current_user.company_id

    respond_to do |format|
      if @service_provider.save
        format.html { redirect_to @service_provider, notice: 'Proveedor creado satisfactoriamente.' }
        format.json { render action: 'show', status: :created, location: @service_provider }
      else
        format.html { render action: 'new' }
        format.json { render json: @service_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_providers/1
  # PATCH/PUT /service_providers/1.json
  def update
    respond_to do |format|

    @users = User.where(company_id: current_user.company_id)
    @locations = Location.where(company_id: current_user.company_id)
      if @service_provider.update(service_provider_params)
        format.html { redirect_to @service_provider, notice: 'Proveedor actualizado satisfactoriamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @service_provider.errors, status: :unprocessable_entity }
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

  def location_services
    services = Service.includes(:service_providers).where('service_providers.location_id = ?', 1).order(:service_category_id)
    render :json => services
  end

  def location_providers
    ServiceProvider.where('location_id = ?', params[:location])
    render :json => ServiceProvider.where('location_id = ?', params[:location])
  end

  def provider_time
    provider_time = ServiceProvider.find(params[:id]).provider_times
    render :json => provider_time
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_provider
      @service_provider = ServiceProvider.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_provider_params
      params.require(:service_provider).permit(:user_id, :location_id, :public_name, :notification_email, :service_ids => [], provider_times_attributes: [:id, :open, :close, :day_id, :service_provider_id, :_destroy])
    end
end
