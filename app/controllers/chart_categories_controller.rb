class ChartCategoriesController < ApplicationController
  before_action :set_chart_category, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json

  def index
    @chart_categories = ChartCategory.all
    respond_with(@chart_categories)
  end

  def show
    respond_with(@chart_category)
  end

  def new
    @chart_category = ChartCategory.new
    respond_with(@chart_category)
  end

  def edit
  end

  def create
    @chart_category = ChartCategory.new(chart_category_params)
    flash[:success] = "Categoría creada." if @chart_category.save
    respond_with(@chart_category) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
    end
  end

  def update
    flash[:success] = "Categoría editada." if @chart_category.update(chart_category_params)
    respond_with(@chart_category) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
    end
  end

  def destroy
    flash[:success] = "Categoría eliminada." if @chart_category.destroy
    respond_with(@chart_category) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
      format.json {
        render json: @chart_category
      }
    end
  end

  private
    def set_chart_category
      @chart_category = ChartCategory.find(params[:id])
    end

    def chart_category_params
      params.require(:chart_category).permit(:chart_field_id, :name)
    end
end
