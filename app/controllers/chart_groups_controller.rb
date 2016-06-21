class ChartGroupsController < ApplicationController
  before_action :set_chart_group, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"
  load_and_authorize_resource

  respond_to :html, :json

  def index
    @chart_groups = ChartGroup.all
    respond_with(@chart_groups)
  end

  def show
    respond_with(@chart_group)
  end

  def new
    @chart_group = ChartGroup.new
    respond_with(@chart_group)
  end

  def edit
    respond_to do |format|
      format.html { render :partial => 'form' }
    end
  end

  def create
    @chart_group = ChartGroup.new(chart_group_params)
    @chart_group.save
    if @chart_group.save
      flash[:success] = "Categoría creada."
    else
      flash[:alert] = @chart_group.errors.full_messages.first
    end
    respond_with(@chart_group) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
    end
  end

  def update
    if @chart_group.update(chart_group_params)
      flash[:success] = "Categoría editada."
    else
      flash[:alert] = @chart_group.errors.full_messages.first
    end
    respond_with(@chart_group) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
    end
  end

  def destroy
    flash[:success] = "Categoría eliminada." if @chart_group.destroy
    respond_with(@chart_group) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'charts') }
    end
  end

  def rearrange

    json_response = []
    json_response[0] = "ok"

    @company = Company.find_by_id(params[:company_id])
    rearrangement = params[:rearrangement]
    logger.debug rearrangement.inspect

    for i in 0..rearrangement.length-1
      chart_group = ChartGroup.find(rearrangement[i])
      if !chart_group.update_column(:order, i+1)
        json_response[0] = "error"
      end
    end

    render :json => json_response

  end

  private
    def set_chart_group
      @chart_group = ChartGroup.find(params[:id])
    end

    def chart_group_params
      params.require(:chart_group).permit(:company_id, :name, :order)
    end
end
