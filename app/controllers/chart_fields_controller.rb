class ChartFieldsController < ApplicationController
  before_action :set_chart_field, only: [:show, :edit, :update, :destroy]

  respond_to :html

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

  def create
    @chart_field = ChartField.new(chart_field_params)
    @chart_field.save
    respond_with(@chart_field)
  end

  def update
    @chart_field.update(chart_field_params)
    respond_with(@chart_field)
  end

  def destroy
    @chart_field.destroy
    respond_with(@chart_field)
  end

  private
    def set_chart_field
      @chart_field = ChartField.find(params[:id])
    end

    def chart_field_params
      params.require(:chart_field).permit(:company_id, :chart_group_id, :name, :description, :datatype, :slug, :mandatory, :order)
    end
end
