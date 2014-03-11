class ServicesController < ApplicationController
  before_action :set_service, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:services_data, :service_data, :get_providers]
  before_action :quick_add, except: [:services_data, :service_data, :get_providers]
  layout "admin", except: [:get_providers, :services_data, :service_data]
  load_and_authorize_resource

  # GET /services
  # GET /services.json
  def index
    @services = Service.where(company_id: current_user.company_id)
  end

  # GET /services/1
  # GET /services/1.json
  def show
  end

  # GET /services/new
  def new
    @service = Service.new
    @service.company_id = current_user.company_id
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services
  # POST /services.json
  def create

    if service_params[:service_category_attributes][:name].nil?
      new_params = service_params.except(:service_category_attributes)
    else
      new_params = service_params.except(:service_category_id)
    end
    @service = Service.new(new_params)
    @service.company_id = current_user.company_id

    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: 'Servicio creado satisfactoriamente.' }
        format.json { render action: 'show', status: :created, location: @service }
      else
        format.html { render action: 'new' }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1
  # PATCH/PUT /services/1.json
  def update
    if service_params[:service_category_attributes][:name].nil?
      new_params = service_params.except(:service_category_attributes)
    else
      new_params = service_params.except(:service_category_id)
    end
    respond_to do |format|
      if @service.update(new_params)
        format.html { redirect_to @service, notice: 'Servicio actualizado satisfactoriamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service.destroy
    respond_to do |format|
      format.html { redirect_to services_url }
      format.json { head :no_content }
    end
  end

  def get_providers
    service = Service.find(params[:id])
    providers = service.service_providers.where('location_id = ?', params[:local])
    render :json => providers
  end

  def service_data
    service = Service.find(params[:id])
    render :json => service
  end

  def services_data
    services = Service.where(:company_id => current_user.company_id)
    render :json => services
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_params
      params.require(:service).permit(:name, :price, :duration, :description, :group_service, :capacity, :waiting_list, :company_id, :service_category_id, service_category_attributes: [:name, :company_id],  :tag_ids => [] )
    end
end
