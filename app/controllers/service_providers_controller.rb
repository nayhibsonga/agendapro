class ServiceProvidersController < ApplicationController
  before_action :set_service_provider, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:location_services, :location_providers, :provider_time]
  before_action :quick_add, except: [:location_services, :location_providers, :provider_time]
  load_and_authorize_resource
  layout "admin", except: [:location_services, :location_providers, :provider_time]

  # GET /service_providers
  # GET /service_providers.json
  def index
    @service_providers = ServiceProvider.where(company_id: current_user.company_id)
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
  end

  # GET /service_providers/1/edit
  def edit
  end

  # POST /service_providers
  # POST /service_providers.json
  def create
    if service_provider_params[:user_attributes] && service_provider_params[:user_attributes][:email].empty?
      new_params = service_provider_params.except(:user_attributes)
    else
      new_params = service_provider_params.except(:user_id)
      new_params[:user_attributes].merge!(:password =>'12345678').merge!(:role_id => Role.find_by_name("Staff").id).merge!(:company_id => current_user.company_id)
    end

    @service_provider = ServiceProvider.new(new_params)
    @service_provider.services.clear
    @service_provider.company_id = current_user.company_id

    respond_to do |format|
      if @service_provider.save
        @service_provider.service_ids = new_params[:service_ids]
        format.html { redirect_to @service_provider, notice: 'Proveedor creado satisfactoriamente.' }
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
    if service_provider_params[:user_attributes] && service_provider_params[:user_attributes][:email].empty?
      new_params = service_provider_params.except(:user_attributes)
    else
      new_params = service_provider_params.except(:user_id)
      new_params[:user_attributes].merge!(:password =>'12345678').merge!(:role_id =>  Role.find_by_name("Staff").id).merge!(:company_id => current_user.company_id)
    end

    @service_provider.services.clear
    @service_provider.provider_times.destroy_all
    respond_to do |format|

    # @users = User.where(company_id: current_user.company_id)
    # @locations = Location.where(company_id: current_user.company_id)
      if @service_provider.update(service_provider_params)
        format.html { redirect_to @service_provider, notice: 'Proveedor actualizado satisfactoriamente.' }
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

  def location_services
    services = Service.includes(:service_providers).where('service_providers.location_id = ?', params[:location]).order(:service_category_id)
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
      params.require(:service_provider).permit(:user_id, :location_id, :public_name, :notification_email, :service_ids => [], provider_times_attributes: [:id, :open, :close, :day_id, :service_provider_id, :_destroy], user_attributes: [:email, :password, :confirm_password, :role_id, :company_id])
    end
end
