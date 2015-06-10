class ServicesController < ApplicationController
  before_action :set_service, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!, except: [:services_data, :service_data, :get_providers, :location_services, :location_categorized_services]
  before_action :quick_add, except: [:services_data, :service_data, :get_providers]
  layout "admin", except: [:get_providers, :services_data, :service_data]
  load_and_authorize_resource

  # GET /services
  # GET /services.json
  def index
    if current_user.role_id == Role.find_by_name('Super Admin').id
      @services = Service.where(company_id: Company.where(owned: false).pluck(:id)).order(order: :asc, name: :asc)
      @service_categories = ServiceCategory.where(company_id: Company.where(owned: false).pluck(:id)).order(:company_id, :order)
    else
      @services = Service.where(company_id: current_user.company_id, :active => true).order(order: :asc, name: :asc)
      @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(order: :asc, name: :asc)
    end
  end

  def inactive_index
    @services = Service.where(company_id: current_user.company_id, :active => false).order(name: :asc)
    @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(name: :asc)
  end

  def activate
    @service.active = true
    @service.save
    redirect_to inactive_services_path
  end

  def deactivate
    @service.active = false
    @service.save
    redirect_to services_path
  end

  # GET /services/1
  # GET /services/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @service }
    end
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
    if service_params[:service_category_attributes]
      if service_params[:service_category_attributes][:name].nil?
        new_params = service_params.except(:service_category_attributes)
      else
        new_params = service_params.except(:service_category_id)
      end
    end
    @service = Service.new(new_params)
    if current_user.role_id != Role.find_by_name("Super Admin").id
      @service.company_id = current_user.company_id
    end

    respond_to do |format|
      if @service.save
        format.html { redirect_to services_path, notice: 'Servicio creado exitosamente.' }
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
    if service_params[:service_category_attributes]
      if service_params[:service_category_attributes][:name].nil?
        new_params = service_params.except(:service_category_attributes)
      else
        new_params = service_params.except(:service_category_id)
      end
    end
    respond_to do |format|
      if @service.update(new_params)
        format.html { redirect_to services_path, notice: 'Servicio actualizado exitosamente.' }
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
    providers = service.service_providers.where(:active => true, online_booking: true).where('location_id = ?', params[:local]).order(order: :asc)
    if params[:admin_origin]
      providers = service.service_providers.where(:active => true).where('location_id = ?', params[:local]).order(order: :asc)
    end
    render :json => providers
  end

  def location_services
    categories = ServiceCategory.where(:company_id => Location.find(params[:location]).company_id).order(order: :asc)
    services = Service.where(:active => true).order(order: :asc).includes(:service_providers).where('service_providers.active = ?', true).where('service_providers.location_id = ?', params[:location]).order(order: :asc)
    render :json => services
  end

  def location_categorized_services

    location_resources = Location.find(params[:location]).resource_locations.pluck(:resource_id)
    service_providers = ServiceProvider.where(location_id: params[:location]).where(:active => true, online_booking: true)
    if params[:admin_origin]
      service_providers = ServiceProvider.where(location_id: params[:location]).where(:active => true)
    end

    categories = ServiceCategory.where(:company_id => Location.find(params[:location]).company_id).order(order: :asc)
    services = Service.where(:active => true, online_booking: true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(order: :asc)

    if params[:admin_origin]
      services = Service.where(:active => true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(order: :asc)
    end

    service_resources_unavailable = ServiceResource.where(service_id: services)
    if location_resources.any?
      if location_resources.length > 1
        service_resources_unavailable = service_resources_unavailable.where('resource_id NOT IN (?)', location_resources)
      else
        service_resources_unavailable = service_resources_unavailable.where('resource_id <> ?', location_resources)
      end
    end
    if service_resources_unavailable.any?
      if service_resources_unavailable.length > 1
        services = services.where('services.id NOT IN (?)', service_resources_unavailable.pluck(:service_id))
      else
        services = services.where('id <> ?', service_resources_unavailable.pluck(:service_id))
      end
    end

    categorized_services = Array.new
    categories.each do |category|
      services_array = Array.new
      services.each do |service|
        if service.service_category_id == category.id
          serviceJSON = service.attributes.merge({'name_with_small_outcall' => service.name_with_small_outcall })
          services_array.push(serviceJSON)
        end
      end
      service_hash = {
        :id => category.id,
        :category => category.name,
        :services => services_array
      }
      categorized_services.push(service_hash)
    end

    render :json => categorized_services
  end

  def service_data
    service = Service.find(params[:id])
    render :json => service
  end

  def services_data
    services = Service.where(:company_id => current_user.company_id)
    render :json => services
  end

  def change_services_order
    array_result = Array.new
    params[:services_order].each do |pos, service_hash|
      service = Service.find(service_hash[:service])
      if service.update(:order => service_hash[:order])
        array_result.push({
          service: service.name,
          status: 'Ok'
        })
      else
        array_result.push({
          service: service.name,
          status: 'Error',
          errors: service.errors
        })
      end
    end
    render :json => array_result
  end

  def set_promotions

    @service = Service.find(params[:service_id])

    array_result = []
    @promos = []
    @errors = []

    if @service.update(:has_last_minute_discount => params[:has_last_minute_discount], :has_time_discount => params[:has_time_discount], :last_minute_hours => params[:last_minute_hours], :last_minute_discount => params[:last_minute_discount])

      #If it has no promotions, create them.
      #Else, update each one.
      if @service.promos.nil? || @service.promos.count == 0

        for i in 1..7
          promo = Promo.new
          promo.service_id = @service.id
          promo.day_id = i
          promo.morning_discount = params[:morning_discounts][i]
          promo.afternoon_discount = params[:afternoon_discounts][i]
          promo.night_discount = params[:night_discounts][i]

          if promo.save
            @promos << promo
          else
            @errors << promo.errors
          end

        end

      else

        for i in 1..7

          promo = Promo.where(:service_id => @service.id, :day_id => i).first

          promo.morning_discount = params[:morning_discounts][i]
          promo.afternoon_discount = params[:afternoon_discounts][i]
          promo.night_discount = params[:night_discounts][i]

          if promo.save
            @promos << promo
          else
            @errors << promo.errors
          end

        end

      end

      if @errors.length == 0
        array_result[0] = "ok"
        array_result[1] = @service
        array_result[2] = @promos
      else
        array_result[0] = "error"
        array_result[1] = @service
        array_result[2] = @errors
      end

    else

      @errors << @service.errors      
      array_result[0] = "error"
      array_result[1] = @service
      array_result[2] = @errors

    end

    render :json => array_result

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_params
      params.require(:service).permit(:name, :price, :show_price, :duration, :outcall, :description, :group_service, :capacity, :waiting_list, :outcall, :online_payable, :online_booking, :has_discount, :discount, :comission_value, :comission_option, :company_id, :service_category_id, :has_sessions, :sessions_amount, service_category_attributes: [:name, :company_id, :id],  :tag_ids => [], :service_provider_ids => [], :resource_ids => [])
    end
end
