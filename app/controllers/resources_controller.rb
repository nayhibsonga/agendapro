class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.where(company_id: current_user.company_id).accessible_by(current_ability).order(:name)
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
  end

  # GET /resources/new
  def new
    if ResourceCategory.where(company_id: current_user.company_id).count == 0
      ResourceCategory.create(name: "Sin Categoría", company_id: current_user.company_id)
    end
    @resource_category = ResourceCategory.new
    @resource = Resource.new
    @resource.resource_locations.build
    @resource_categories = ResourceCategory.where(company_id: current_user.company_id).order(:name)
    @locations = Location.where(company_id: current_user.company_id, active: true).accessible_by(current_ability).order(:order)
  end

  # GET /resources/1/edit
  def edit
    @resource_category = ResourceCategory.new
    @resource_categories = ResourceCategory.where(company_id: current_user.company_id).order(:name)
    @locations = Location.where(company_id: current_user.company_id, active: true).accessible_by(current_ability).order(:order)
  end

  # POST /resources
  # POST /resources.json
  def create
    # new_resource_params = resource_params.except(:resource_locations_attributes)
    @resource = Resource.new(resource_params)
    @resource.company_id = current_user.company_id

    respond_to do |format|
      if @resource.save
        format.html { redirect_to resources_path, notice: 'Recurso creado exitosamente.' }
        format.json { render :json => @resource }
      else
        format.html { render action: 'new' }
        format.json { render :json => { :errors => @resource.errors.full_messages }, :status => 422 }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    @resource.resource_locations.destroy_all

    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to resources_path, notice: 'Recurso actualizado exitosamente.' }
        format.json { render :json => @resource }
      else
        format.html { render action: 'edit' }
        format.json { render :json => { :errors => @resource.errors.full_messages }, :status => 422 }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:name, :resource_category_id, :resource_locations_attributes => [:id, :location_id, :quantity])
    end
end
