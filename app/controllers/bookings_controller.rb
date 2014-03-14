class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:create, :provider_booking, :book_service, :edit_booking, :edit_booking_post, :cancel_booking]
  before_action :quick_add, except: [:create, :provider_booking, :book_service, :edit_booking, :edit_booking_post, :cancel_booking]
  layout "admin", except: [:book_service, :provider_booking, :edit_booking, :edit_booking_post, :cancel_booking]
  load_and_authorize_resource

  # GET /bookings
  # GET /bookings.json
  def index
    @company = Company.where(id: current_user.company_id)
    @locations = Location.all.accessible_by(current_ability)
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
    if !booking_params[:user_id]
      if User.find_by_email(booking_params[:email])
        @booking.user_id = User.find_by_email(booking_params[:email]).id
      end
    end
    if @booking && @booking.service_provider
      @booking.location = @booking.service_provider.location
    end
    respond_to do |format|
      if @booking.save
        format.html { redirect_to @booking, notice: 'Booking was successfully created.' }
        format.json { render :json => @booking }
        format.js { }
      else
        format.html { render action: 'new' }
        format.json { render :json => { :errors => @booking.errors.full_messages }, :status => 422 }
        format.js { }
      end
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    @booking.location = @booking.service_provider.location
    if !booking_params[:user_id]
      if User.find_by_email(booking_params[:email])
        @booking.user_id = User.find_by_email(booking_params[:email]).id
      end
    end
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { render :json => @booking }
        format.js { }
      else
        format.html { render action: 'edit' }
        format.json { render :json => { :errors => @booking.errors.full_messages }, :status => 422 }
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
    @provider = params[:provider]
    if @provider.nil?
      @provider = ServiceProvider.where(:location_id => params[:location])
    end
    @bookings = Booking.where(:service_provider_id => @provider, :location_id => params[:location]).order(:start)
    render :json => @bookings
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

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def edit_booking
    code = params[:confirmation_code].split('-')
    id = code[0][0,code[1].to_i].to_i
    @booking = Booking.find(id)
    @company = Location.find(@booking.location_id).company

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def edit_booking_post
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company

    if @booking.update(start: params[:start], end: params[:end])
      flash[:notice] = "Cita actualizada."
      BookingMailer.update_booking(@booking)
    else
      flash[:alert] = "Error actualizando cita."
      @errors = @booking.errors
    end

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def cancel_booking
    unless params[:id]
      code = params[:confirmation_code].split('-')
      id = code[0][0,code[1].to_i].to_i
      @booking = Booking.find(id)
    else
      @booking = Booking.find(params[:id])
      status = Status.find_by(:name => 'Cancelado').id
      if @booking.update(status_id: status)
        flash[:notice] = "Cita cancelada."
        BookingMailer.cancel_booking(@booking)
      else
        flash[:alert] = "Error cancelando cita."
        @errors = @booking.errors
      end
    end

    @company = Location.find(@booking.location_id).company

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: 'workflow'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:start, :end, :notes, :service_provider_id, :service_id, :user_id, :status_id, :promotion_id, :first_name, :last_name, :email, :phone, :confirmation_code)
    end
end
