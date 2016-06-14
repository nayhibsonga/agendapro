class ChartsController < ApplicationController
  before_action :set_chart, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json

  def index
    @charts = Chart.all
    respond_with(@charts)
  end

  def show
    respond_with(@chart)
  end

  def new
    @chart = Chart.new
    respond_with(@chart)
  end

  def edit
  end

  def create
    @chart = Chart.new(chart_params)
    if @chart.save
      @chart.save_chart_fields(params)
      flash[:success] = "Ficha creada."
    else
      flash[:alert] = "Error al crear la ficha."
    end
    respond_with(@chart)
  end

  def update
    @chart.update(chart_params)
    respond_with(@chart)
  end

  def destroy
    @chart.destroy
    respond_with(@chart)
  end

  private
    def set_chart
      @chart = Chart.find(params[:id])
    end

    def chart_params
      params.require(:chart).permit(:company_id, :client_id, :booking_id, :user_id, :date)
    end
end
