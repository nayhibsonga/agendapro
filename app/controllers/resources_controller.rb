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
    @resource_category = ResourceCategory.new
    @resource = Resource.new
    @resource_categories = ResourceCategory.where(company_id: current_user.company_id)
    @locations = Location.where(company_id: current_user.company_id, active: true).accessible_by(current_ability).order(:order)
  end

  # GET /resources/1/edit
  def edit
    @resource_category = ResourceCategory.new
    @resource_categories = ResourceCategory.where(company_id: current_user.company_id)
    @locations = Location.where(company_id: current_user.company_id, active: true).accessible_by(current_ability).order(:order)
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)

    respond_to do |format|
      if @resource.save
        format.html { redirect_to resources_path, notice: 'El recurso fue creado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @resource }
      else
        format.html { render action: 'new' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to resources_path, notice: 'El recurso fue editado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
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
      params.require(:resource).permit(:name, :location_ids)
    end
end
