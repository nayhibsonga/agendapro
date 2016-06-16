class ChartsController < ApplicationController
  before_action :set_chart, only: [:show, :edit, :update, :destroy, :summary]
  before_action :authenticate_user!
  load_and_authorize_resource

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
      flash[:success] = "Ficha creada exitosamente."
    else
      flash[:alert] = "Error al crear la ficha."
    end
    respond_with(@chart) do |format|
      format.html { redirect_to client_charts_path(@chart.client) }
    end
  end

  def update
    @chart.update(chart_params)
    respond_with(@chart)
  end

  def destroy
    @chart.destroy
    respond_with(@chart)
  end

  #Return bookings (including booked sessions) between two dates
  def bookings
    @client = Client.find(params[:client_id])
    @from = params[:from].to_datetime.beginning_of_day
    @to = params[:to].to_datetime.end_of_day
    @bookings = []
    @client.bookings.where('is_session = false or (is_session = true and is_session_booked = true)').where.not(id: @client.charts.pluck(:booking_id)).where(start: @from..@to).order(start: :desc).each do |booking|
      session_number = 0
      sessions_amount = 0
      if booking.is_session && !booking.session_booking.nil?
        session_number = booking.session_booking.bookings.where(is_session_booked: true).where('start < ?', booking.start).count + 1
        sessions_amount = booking.session_booking.sessions_amount
      end
      @bookings << {id: booking.id, service_name: booking.service.name, start: booking.start.strftime("%d/%m/%Y %R"), provider_name: booking.service_provider.public_name, is_session: booking.is_session, session_number: session_number, sessions_amount: sessions_amount}
    end
    render :json => @bookings
  end

  def summary
    render "_summary", layout: false
  end

  private
    def set_chart
      @chart = Chart.find(params[:id])
    end

    def chart_params
      params.require(:chart).permit(:company_id, :client_id, :booking_id, :user_id, :date)
    end
end
