class ChartFieldsController < ApplicationController
  before_action :set_chart_field, only: [:show, :edit, :update, :destroy, :edit_form]
  before_action :authenticate_user!
  layout "admin"
  load_and_authorize_resource

  respond_to :html, :json

  def index
    @chart_fields = ChartField.all
    respond_with(@chart_fields)
  end

  def show
    respond_with(@chart_field)
  end

  def new
    @chart_field = ChartField.new
    respond_with(@chart_field)
  end

  def edit
  end

  def get_chart_categories
    @chart_field = ChartField.find(params[:chart_field_id])
    @chart_categories = @chart_field.chart_categories
    render :json => @chart_categories
  end

  def create
    @chart_field = ChartField.new(chart_field_params)
    flash[:success] = "Campo creado." if @chart_field.save
    respond_with(@chart_field) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
    end
  end

  def update
    flash[:success] = "Campo editado." if @chart_field.update(chart_field_params)
    respond_with(@chart_field) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
    end
  end

  def destroy
    flash[:success] = "Campo eliminado." if @chart_field.destroy
    respond_with(@chart_field) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
    end
  end

  def edit_form
    @chart_groups = @chart_field.company.chart_groups.order(name: :asc)
    respond_to do |format|
        format.html { render :partial => 'edit_chart_field' }
    end
  end

  def rearrange

    json_response = []
    json_response[0] = "ok"

    @company = Company.find_by_id(params[:company_id])
    rearrangement = params[:rearrangement]

    for i in 0..rearrangement.length - 1
      chart_field = ChartField.find(rearrangement[i])
      if !chart_field.update_column(:order, i + 1)
        json_response[0] = "error"
      end
    end

    render :json => json_response

  end

  private
    def set_chart_field
      @chart_field = ChartField.find(params[:id])
    end

    def chart_field_params
      params.require(:chart_field).permit(:company_id, :chart_group_id, :name, :description, :datatype, :slug, :mandatory, :order)
    end
end
