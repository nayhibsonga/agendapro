class ServiceCategoriesController < ApplicationController
  before_action :set_service_category, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:get_category_name]
  before_action :quick_add, except: [:get_category_name]
  layout "admin", except: [:get_category_name]
  load_and_authorize_resource

  # GET /service_categories
  # GET /service_categories.json
  def index
    @service_categories = ServiceCategory.where(:company_id => current_user.company_id)
  end

  # GET /service_categories/1
  # GET /service_categories/1.json
  def show
  end

  # GET /service_categories/new
  def new
    @service_category = ServiceCategory.new
    @service_category.company_id = current_user.company_id
  end

  # GET /service_categories/1/edit
  def edit
    if @service_category.name == "Sin Categoría"
      redirect_to service_categories_path, notice: 'No es posible editar la categoría "Sin Categoría".'
    end
  end

  # POST /service_categories
  # POST /service_categories.json
  def create
    @service_category = ServiceCategory.new(service_category_params)
    @service_category.company_id = current_user.company_id

    respond_to do |format|
      if @service_category.save
        format.html { redirect_to , notice: service_categories_path'La Categoría de Servicios ha sido creada exitosamente.' }
        format.json { render action: 'show', status: :created, location: @service_category }
      else
        format.html { render action: 'new' }
        format.json { render json: @service_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_categories/1
  # PATCH/PUT /service_categories/1.json
  def update
    if @service_category.name == "Sin Categoría"
      redirect_to service_categories_path, notice: 'No es posible actualizar la categoría "Sin Categoría".'
    end
    respond_to do |format|
      if @service_category.update(service_category_params)
        format.html { redirect_to service_categories_path, notice: 'La Categoría de Servicios ha sido actualizada exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @service_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_categories/1
  # DELETE /service_categories/1.json
  def destroy
    if @service_category.name == "Sin Categoría"
      redirect_to service_categories_path, notice: 'No es posible eliminar la categoría "Sin Categoría".'
    end
    @services = Service.where(service_category_id: @service_category)
    @new_service_category = ServiceCategory.where(company_id: @service_category.company_id, name: "Sin Categoría").first
    if @new_service_category.nil?
      @new_service_category = ServiceCategory.create(name: "Sin Categoría", company_id: @service_category.company_id)
      @new_service_category.save
    end
    @services.each do |service|
      service.service_category = @new_service_category
      service.save
    end
    @service_category.destroy
    respond_to do |format|
      format.html { redirect_to service_categories_url }
      format.json { head :no_content }
    end
  end

  def get_category_name
    @service_category = ServiceCategory.find(params[:id])
    render :json => @service_category
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_category
      @service_category = ServiceCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_category_params
      params.require(:service_category).permit(:name, :company_id)
    end
end
