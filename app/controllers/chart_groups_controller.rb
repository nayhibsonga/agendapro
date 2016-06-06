class ChartGroupsController < ApplicationController
  before_action :set_chart_group, only: [:show, :edit, :update, :destroy]

  respond_to :html

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
  end

  def create
    @chart_group = ChartGroup.new(chart_group_params)
    @chart_group.save
    respond_with(@chart_group)
  end

  def update
    @chart_group.update(chart_group_params)
    respond_with(@chart_group)
  end

  def destroy
    @chart_group.destroy
    respond_with(@chart_group)
  end

  private
    def set_chart_group
      @chart_group = ChartGroup.find(params[:id])
    end

    def chart_group_params
      params.require(:chart_group).permit(:company_id, :name, :order)
    end
end
