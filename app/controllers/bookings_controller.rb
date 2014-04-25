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
    @locations = Location.where(:active => true).accessible_by(current_ability)
    @service_providers = ServiceProvider.where(location_id: @locations)
    @bookings = Booking.where(service_provider_id: @service_providers)
    @booking = Booking.new
    @provider_break = ProviderBreak.new
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
        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => @booking }
        format.js { }
      else
        format.html { render action: 'new' }
        format.json { render :json => { :errors => @booking.errors.full_messages }, :status => 422 }
        format.js { }
      end
    end
  end

  def create_provider_break
    @provider_break = ProviderBreak.new(provider_break_params)
    respond_to do |format|
      if @provider_break.save
        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => @provider_break }
        format.js { }
      else
        format.html { render action: 'index' }
        format.json { render :json => { :errors => @provider_break.errors.full_messages }, :status => 422 }
        format.js { }
      end
    end
  end

  def provider_breaks
    provider_breaks = ProviderBreak.where(service_provider_id: params[:service_provider_id])
    render :json => provider_breaks
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    if ServiceProvider.where(:id => booking_params[:service_provider_id])
      booking_params[:location_id] = ServiceProvider.find(booking_params[:service_provider_id]).location.id
    end
    if !booking_params[:user_id]
      if User.find_by_email(booking_params[:email])
        @booking.user_id = User.find_by_email(booking_params[:email]).id
      end
    end
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to bookings_path, notice: 'Booking was successfully updated.' }
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
    status = Status.find_by(:name => 'Cancelado').id
    @booking.update(status_id: status)
    # @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { head :no_content }
    end
  end

  def get_booking
    booking = Booking.find(params[:id])
    render :json => booking
  end

  def get_booking_info
    booking = Booking.find(params[:id])
    render :json => {service_provider_active: booking.service_provider.active, service_active: booking.service.active, service_provider_name: booking.service_provider.public_name, service_name: booking.service.name}
  end

  def provider_booking
    @provider = params[:provider]
    if @provider.nil?
      @provider = ServiceProvider.where(:location_id => params[:location])
    end
    @bookings = Booking.where(:service_provider_id => @provider, :location_id => params[:location]).order(:start)
    @booklist = @bookings.map do |u|
      { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :user_id => u.user_id, :status_id => u.user_id, :first_name => u.first_name, :last_name => u.last_name, :email => u.email, :phone => u.phone, :notes => u.notes, service_provider_active: u.service_provider.active, service_active: u.service.active, service_provider_name: u.service_provider.public_name, service_name: u.service.name}
    end

    json = @booklist.to_json
    render :json => json
  end

  def book_service
    if user_signed_in?
      @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, first_name: params[:firstName], last_name: params[:lastName], email: params[:email], phone: params[:phone], user_id: current_user.id)
    else
      @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, first_name: params[:firstName], last_name: params[:lastName], email: params[:email], phone: params[:phone])
    end
    if @booking.save
      flash[:notice] = "Servicio agendado"

      # BookingMailer.book_service_mail(@booking)
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
      # BookingMailer.update_booking(@booking)
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
        # BookingMailer.cancel_booking(@booking)
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

    def provider_break_params
      params.require(:provider_break).permit(:start, :end, :service_provider_id)
    end
end
