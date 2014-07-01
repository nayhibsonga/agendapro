class ResourceCategoriesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  # GET /resources
  # GET /resources.json
  def index
    @resource_categories = ResourceCategory.where(company_id: current_user.company_id).accessible_by(current_ability).order(:name)
    render :json => @resource_categories
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
  end

  # GET /resources/new
  def new
    @resource_category = ResourceCategory.new
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource_category = ResourceCategory.new(resource_category_params)
    @resource_category.company_id = current_user.company_id

    respond_to do |format|
      if @resource_category.save
        format.html { redirect_to resource_categories_path, notice: 'La categoría de recursos fue creada exitosamente.' }
        format.json { render :json => @resource_category }
      else
        format.html { render action: 'new' }
        format.json { render :json => { :errors => @resource_category.errors.full_messages }, :status => 422 }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    respond_to do |format|
      if @resource_category.update(resource_category_params)
        format.html { redirect_to resource_categories_path, notice: 'La categoría recursos fue editada exitosamente.' }
        format.json { render :json => @resource_category }
      else
        format.html { render action: 'edit' }
        format.json { render :json => { :errors => @resource_category.errors.full_messages }, :status => 422 }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    if @resource_category.name == "Sin Categoría"
      render :json => { :errors => 'No es posible eliminar la categoría "Sin Categoría".' }, :status => 422
    else
      @resources = Resource.where(resource_category_id: @resource_category)
      @new_resource_category = ResourceCategory.where(company_id: @resource_category.company_id, name: "Sin Categoría").first
      if @new_resource_category.nil?
        @new_resource_category = ResourceCategory.create(name: "Sin Categoría", company_id: @resource_category.company_id)
        @new_resource_category.save
      end
      @resources.each do |resource|
        resource.resource_category = @new_resource_category
        resource.save
      end
      @resource_category.destroy
      respond_to do |format|
        format.html { redirect_to resource_categories_url }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = ResourceCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_category_params
      params.require(:resource_category).permit(:name)
    end
end
