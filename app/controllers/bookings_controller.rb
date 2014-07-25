class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:create, :provider_booking, :book_service, :edit_booking, :edit_booking_post, :cancel_booking, :confirm_booking, :check_user_cross_bookings, :blocked_edit]
  before_action :quick_add, except: [:create, :provider_booking, :book_service, :edit_booking, :edit_booking_post, :cancel_booking, :confirm_booking, :check_user_cross_bookings, :blocked_edit]
  layout "admin", except: [:book_service, :provider_booking, :edit_booking, :edit_booking_post, :cancel_booking, :confirm_booking, :check_user_cross_bookings, :blocked_edit, :blocked_cancel]

  # GET /bookings
  # GET /bookings.json
  def index
    @company = Company.where(id: current_user.company_id)
    if current_user.role_id == Role.find_by_name("Staff").id
      @locations = Location.where(:active => true, :id => ServiceProvider.where(active: true, user_id: current_user.id).pluck(:location_id)).accessible_by(current_ability).order(:order)
    else
      @locations = Location.where(:active => true).accessible_by(current_ability).order(:order)
    end
    @service_providers = ServiceProvider.where(location_id: @locations).order(:order)
    @bookings = Booking.where(service_provider_id: @service_providers)
    @booking = Booking.new
    @provider_break = ProviderBreak.new
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
    u = @booking
    @booking_json = { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :price => u.price, :status_id => u.status_id, :client_id => u.client.id, :first_name => u.client.first_name, :last_name => u.client.last_name, :email => u.client.email, :phone => u.client.phone, :send_mail => u.send_mail, :notes => u.notes,  :company_comment => u.company_comment, :service_provider_active => u.service_provider.active, :service_active => u.service.active, :service_provider_name => u.service_provider.public_name, :service_name => u.service.name }
    respond_to do |format|
      format.html { }
      format.json { render :json => @booking_json }
    end
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
    new_booking_params = booking_params.except(:client_first_name, :client_last_name, :client_phone, :client_email)
    @booking = Booking.new(new_booking_params)
    if !booking_params[:client_id].nil? && !booking_params[:client_id].empty?
      @client = Client.find(booking_params[:client_id])
      @client.email = booking_params[:client_email]
      @client.phone = booking_params[:client_phone]
      @client.save
      if User.find_by_email(@client.email)
        new_booking_params[:user_id] = User.find_by_email(@client.email).id
      end
    else
      if !booking_params[:client_email].nil?
        if booking_params[:client_email].empty?
          if Client.where(email: '', company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => booking_params[:client_first_name]+' '+booking_params[:client_last_name]).count > 0
            client = Client.where(email: '', company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => booking_params[:client_first_name]+' '+booking_params[:client_last_name]).first
            @booking.client = client
          else
            client = Client.new(email: booking_params[:client_email], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
            if client.save
              @booking.client = client
            end
          end
        else
          if Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).count > 0
            client = Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).first
            @booking.client = client
          else
            client = Client.new(email: booking_params[:client_email], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
            if client.save
              @booking.client = client
            end
          end
        end
        if User.find_by_email(booking_params[:client_email])
          new_booking_params[:user_id] = User.find_by_email(booking_params[:client_email]).id
        end
      end
    end
    if @booking && @booking.service_provider
      @booking.location = @booking.service_provider.location
    end
    respond_to do |format|
      if @booking.save
        u = @booking
        @booking_json = { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :status_id => u.status_id, :first_name => u.client.first_name, :last_name => u.client.last_name, :email => u.client.email, :phone => u.client.phone, :notes => u.notes,  :company_comment => u.company_comment }
        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => [@booking_json, @booking.service.name] }
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
    new_booking_params = booking_params.except(:client_first_name, :client_last_name, :client_phone, :client_email)
    if !booking_params[:client_id].nil? && !booking_params[:client_id].empty?
      @client = Client.find(booking_params[:client_id])
      @client.email = booking_params[:client_email]
      @client.phone = booking_params[:client_phone]
      @client.save
      if User.find_by_email(booking_params[:client_email])
        new_booking_params[:user_id] = User.find_by_email(booking_params[:client_email]).id
      end
    else
      if !booking_params[:client_email].nil?
        if booking_params[:client_email].empty?
          if Client.where(email: '', company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => booking_params[:client_first_name]+' '+booking_params[:client_last_name]).count > 0
            client = Client.where(email: '', company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => booking_params[:client_first_name]+' '+booking_params[:client_last_name]).first
            new_booking_params[:client_id] = client.id
          else
            client = Client.new(email: '', first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
            if client.save
              new_booking_params[:client_id] = client.id
            end
          end
        else
          if Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).count > 0
            client = Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).first
            new_booking_params[:client_id] = client.id
          else
            client = Client.new(email: booking_params[:client_email], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
            if client.save
              new_booking_params[:client_id] = client.id
            end
          end
        end
        if User.find_by_email(booking_params[:client_email])
          new_booking_params[:user_id] = User.find_by_email(booking_params[:client_email]).id
        end
      end
    end
    if ServiceProvider.where(:id => booking_params[:service_provider_id])
      new_booking_params[:location_id] = ServiceProvider.find(booking_params[:service_provider_id]).location.id
    end
    respond_to do |format|
      if @booking.update(new_booking_params)
        u = @booking
        @booking_json = { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :status_id => u.status_id, :first_name => u.client.first_name, :last_name => u.client.last_name, :email => u.client.email, :phone => u.client.phone, :send_mail => u.send_mail, :notes => u.notes,  :company_comment => u.company_comment }
        format.html { redirect_to bookings_path, notice: 'Booking was successfully updated.' }
        format.json { render :json => [@booking_json, @booking.service.name] }
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
      format.json { render :json => @booking }
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
    start_date = DateTime.parse(params[:start])
    end_date = DateTime.parse(params[:end])
    @bookings = Booking.where(:service_provider_id => @provider, :location_id => params[:location]).where('(bookings.start,bookings.end) overlaps (date ?,date ?)', end_date, start_date).order(:start)
    @booklist = @bookings.map do |u|
      { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :user_id => u.user_id, :status_id => u.status_id, :first_name => u.client.first_name, :last_name => u.client.last_name, :email => u.client.email, :phone => u.client.phone, :send_mail => u.send_mail, :notes => u.notes, service_provider_active: u.service_provider.active, service_active: u.service.active, service_provider_name: u.service_provider.public_name, service_name: u.service.name, web_origin: u.web_origin}
    end

    json = @booklist.to_json
    render :json => json
  end

  def book_service
    @company = Location.find(params[:location]).company
    if params[:address] && !params[:address].empty?
      params[:comment] += ' - Dirección del cliente (donde se debe realizar el servicio): ' + params[:address]
    end
    if Client.where(email: params[:email], company_id: @company).count > 0
      client = Client.where(email: params[:email], company_id: @company).first
    else
      client = Client.new(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], company_id: @company.id)
      client.save
    end
    if user_signed_in?
      @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, client_id: client.id, user_id: current_user.id, web_origin: params[:origin])
    else
      if User.find_by_email(params[:email])
        @user = User.find_by_email(params[:email])
        @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, client_id: client.id, user_id: @user.id, web_origin: params[:origin])
      else
        @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, client_id: client.id, web_origin: params[:origin])
      end
    end
    @booking.price = Service.find(params[:service]).price
    if @booking.save
      flash[:notice] = "Servicio agendado"

      # BookingMailer.book_service_mail(@booking)
    else
      flash[:alert] = "Error guardando datos de agenda"
      @errors = @booking.errors
    end

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def edit_booking
    require 'date'

    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    id = crypt.decrypt_and_verify(params[:confirmation_code])
    @booking = Booking.find(id)
    @company = Location.find(@booking.location_id).company

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
    booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0
    if (booking_start <=> now) < 1
      redirect_to blocked_edit_path(:id => @booking.id)
      return
    end

    if mobile_request?
      @service = @booking.service
      @provider = @booking.service_provider

      # Data
      date = Date.parse(@booking.start.to_s)
      service_duration = @service.duration
      company_setting = @company.company_setting
      provider_breaks = ProviderBreak.where(:service_provider_id => @provider.id)

      @available_time = Array.new

      # Variable Data
      provider_times = @provider.provider_times.where(day_id: date.cwday).order(:open)
      bookings = @provider.bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).order(:start)

      # Hour Blocks
      $i = 0
      $length = provider_times.length
      while $i < $length do
        provider_time = provider_times[$i]
        provider_time_open = provider_time.open
        provider_time_close = provider_time.close

        # => Available/Occupied Blocks
        while (provider_time_open <=> provider_time_close) < 0 do
        block_hour = Hash.new

        # Tmp data
        open_hour = provider_time_open.hour
        open_min = provider_time_open.min

        start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

        provider_time_open += service_duration.minutes

        # Tmp data
        next_open_hour = provider_time_open.hour
        next_open_min = provider_time_open.min

        end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s

        # Block Hour
        hour = {
          :start => start_block,
          :end => end_block
        }

        # Status
        status = 'available'
        start_time_block = DateTime.new(date.year, date.mon, date.mday, open_hour, open_min)
        end_time_block = DateTime.new(date.year, date.mon, date.mday, next_open_hour, next_open_min)
        
        # Past hours
        now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
        before_now = start_time_block - company_setting.before_booking / 24.0
        after_now = now + company_setting.after_booking * 30

        provider_breaks.each do |provider_break|
          break_start = DateTime.parse(provider_break.start.to_s)
          break_end = DateTime.parse(provider_break.end.to_s)
          if  (break_start - end_time_block) * (start_time_block - break_end) > 0
          status = 'occupied'
          end
        end

        if (before_now <=> now) < 1
          status = 'past'
        elsif (after_now <=> end_time_block) < 1
          status = 'past'
        else
          bookings.each do |booking|
          booking_start = DateTime.parse(booking.start.to_s)
          booking_end = DateTime.parse(booking.end.to_s)

          if (booking_start - end_time_block) * (start_time_block - booking_end) > 0 && booking.status_id != Status.find_by(name: 'Cancelado').id
            if !@service.group_service || @service.id != booking.service_id
            status = 'occupied'
            elsif @service.group_service && @service.id == booking.service_id && @provider.bookings.where(:service_id => @service.id, :start => booking.start).count >= @service.capacity
            status = 'occupied'
            end
          end
          end
        end

        block_hour[:date] = date
        block_hour[:hour] = hour

        @available_time << block_hour if status == 'available'
        end

        $i += 1
      end

      @available_time
    end

    render layout: "workflow"
  end

  def blocked_edit
    @booking = Booking.find(params[:id])
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
      flash[:notice] = "Reserva actualizada exitosamente."
      # BookingMailer.update_booking(@booking)
    else
      flash[:alert] = "Hubo un error actualizando tu reserva."
      @errors = @booking.errors
    end

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def confirm_booking
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    id = crypt.decrypt_and_verify(params[:confirmation_code])
    @booking = Booking.find(id)
    @company = Location.find(@booking.location_id).company

    @booking.update(:status => Status.find_by(:name => 'Confirmado'))

    render layout: 'workflow'
  end

  def blocked_cancel
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def cancel_booking
    require 'date'

    unless params[:id]
      crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
      id = crypt.decrypt_and_verify(params[:confirmation_code])
      @booking = Booking.find(id)
      @company = Location.find(@booking.location_id).company
      
      now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
      booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0
      
      if (booking_start <=> now) < 1
        redirect_to blocked_cancel_path(:id => @booking.id)
        return
      end
      
    else
      @booking = Booking.find(params[:id])
      status = Status.find_by(:name => 'Cancelado').id
      
      if @booking.update(status_id: status)
        flash[:notice] = "Reserva cancelada exitosamente."
        # BookingMailer.cancel_booking(@booking)
      else
        flash[:alert] = "Hubo un error cancelando tu reserva."
        @errors = @booking.errors
      end
    end

    @company = Location.find(@booking.location_id).company

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: 'workflow'
  end

  def check_user_cross_bookings
    require 'date'
    if !params[:user].blank?
      bookings = Booking.where(:user_id => params[:user], :status_id => [Status.find_by(:name => 'Reservado'), Status.find_by(:name => 'Pagado'), Status.find_by(:name => 'Confirmado')])
      booking_start = DateTime.parse(params[:booking_start])
      booking_end = DateTime.parse(params[:booking_end])
      bookings.each do |booking|
        book_start = DateTime.parse(booking.start.to_s)
        book_end = DateTime.parse(booking.end.to_s)
        if (book_start - booking_end) * (booking_start - book_end) > 0
          render :json => {
            :crossover => true,
            :booking => {
              :service => booking.service.name,
              :service_provider => booking.service_provider.public_name,
              :start => booking.start,
              :end => booking.end
            }
          }
          return
        end
      end
    end
    render :json => {:crossover => false}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:start, :end, :notes, :service_provider_id, :service_id, :price, :user_id, :status_id, :promotion_id, :client_id, :client_first_name, :client_last_name, :client_email, :client_phone, :confirmation_code, :company_comment, :web_origin, :send_mail)
    end

    def provider_break_params
      params.require(:provider_break).permit(:start, :end, :service_provider_id)
    end
end
