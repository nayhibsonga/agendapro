class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:create, :provider_booking, :book_service]
  before_action :quick_add, except: [:create, :provider_booking, :book_service]
  layout "admin", except: [:book_service, :provider_booking]
  load_and_authorize_resource

  # GET /bookings
  # GET /bookings.json
  def index
    @company = Company.where(id: current_user.company_id)
    @locations = Location.where(company_id: @company)
    @service_providers = ServiceProvider.where(location_id: @locations)
    @bookings = Booking.where(service_provider_id: @service_providers)
    @booking = Booking.new
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @booking = Booking.new(booking_params)
    @booking.location = @booking.service_provider.location

    respond_to do |format|
      if @booking.save
        format.html { redirect_to @booking, notice: 'Booking was successfully created.' }
        format.json { render action: 'show', status: :created, location: @booking }
        format.js { }
      else
        format.html { render action: 'new' }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
        format.js { }
      end
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
        format.js { }
      else
        format.html { render action: 'edit' }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
        format.js { }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { head :no_content }
    end
  end

  def get_booking
    @booking = Booking.find(params[:id])
    booking = Booking.find(params[:id])
    render :json => booking
  end

  def provider_booking
    if params[:provider].nil?
      params[:provider] = ServiceProvider.where(:location_id => params[:location])
    end
    bookings = Booking.where(:service_provider_id => params[:provider], :location_id => params[:location]).order(:start)
    render :json => bookings
  end

  def book_service
    if user_signed_in?
      @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, first_name: params[:firstName], last_name: params[:lastName], email: params[:email], phone: params[:phone], user_id: current_user.id)
    else
      @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, first_name: params[:firstName], last_name: params[:lastName], email: params[:email], phone: params[:phone])
    end
    if @booking.save
      flash[:notice] = "Servicio agendado"

      BookingMailer.book_service_mail(@booking)
    else
      flash[:alert] = "Error guardando datos de agenda"
      @errors = @booking.errors
    end
    @company = Location.find(params[:location]).company
    render layout: "workflow"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:start, :end, :notes, :service_provider_id, :service_id, :user_id, :status_id, :promotion_id, :first_name, :last_name, :email, :phone, :_, :booking)
    end
end
