class AttributeCategoriesController < ApplicationController
  before_action :set_attribute_category, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json

  def index
    @attribute_categories = AttributeCategory.all
    respond_with(@attribute_categories)
  end

  def show
    respond_with(@attribute_category)
  end

  def new
    @attribute_category = AttributeCategory.new
    respond_with(@attribute_category)
  end

  def edit
  end

  def create
    @attribute_category = AttributeCategory.new(attribute_category_params)
    flash[:notice] = "Categoría creada." if @attribute_category.save
    respond_with(@attribute_category) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
    end
  end

  def update
    flash[:notice] = "Categoría editada." if @attribute_category.update(attribute_category_params)
    respond_with(@attribute_category) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
    end
  end

  def destroy
    flash[:notice] = "Categoría eliminada." if @attribute_category.destroy
    respond_with(@attribute_category) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
      format.json {
        render json: @attribute_category
      }
    end
  end

  private
    def set_attribute_category
      @attribute_category = AttributeCategory.find(params[:id])
    end

    def attribute_category_params
      params.require(:attribute_category).permit(:attribute_id, :category)
    end
end
