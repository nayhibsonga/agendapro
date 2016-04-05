class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy, :delete_session_booking, :validate_session_booking, :session_booking_detail, :book_session_form, :get_treatment_info, :delete_treatment]
  before_action :authenticate_user!, except: [:create, :force_create, :booking_valid, :provider_booking, :book_service, :book_error, :remove_bookings, :edit_booking, :edit_booking_post, :cancel_booking, :cancel_all_booking, :confirm_booking, :confirm_all_bookings, :confirm_error, :confirm_success, :check_user_cross_bookings, :blocked_edit, :blocked_cancel, :optimizer_hours, :optimizer_data, :transfer_error_cancel, :promotion_hours]
  before_action :quick_add, except: [:create, :force_create, :booking_valid, :provider_booking, :book_service, :book_error, :remove_bookings, :edit_booking, :edit_booking_post, :cancel_booking, :confirm_booking, :check_user_cross_bookings, :blocked_edit, :blocked_cancel, :optimizer_hours, :optimizer_data, :transfer_error_cancel]
  layout "admin", except: [:book_service, :book_error, :remove_bookings, :provider_booking, :edit_booking, :edit_booking_post, :cancel_booking, :transfer_error_cancel, :confirm_booking, :check_user_cross_bookings, :blocked_edit, :blocked_cancel, :optimizer_hours, :optimizer_data]

  #load_and_authorize_resource

  # GET /bookings
  # GET /bookings.json
  def index
    if current_user.role_id == Role.find_by_name("Staff (sin edición)").id
      redirect_to fixed_bookings_path
    end

    @company = Company.find(current_user.company_id)
    if current_user.role_id == Role.find_by_name("Staff").id || current_user.role_id == Role.find_by_name("Staff (sin edición)").id
      @locations = Location.actives.where(id: ServiceProvider.actives.where(id: UserProvider.where(user_id: current_user.id).pluck(:service_provider_id)).pluck(:location_id)).accessible_by(current_ability).ordered
    else
      @locations = Location.actives.accessible_by(current_ability).ordered
    end
    @company_setting = @company.company_setting
    @service_providers = ServiceProvider.where(location_id: @locations).ordered
    @provider_groups = JbuilderTemplate.encode(view_context) do |json|
      json.array! ProviderGroup.where(company_id: current_user.company_id).order(:order, :name) do |provider_group|
        json.name  provider_group.name
        json.location_id provider_group.location_id
        json.resources provider_group.service_providers.actives.accessible_by(current_ability).ordered do |service_provider|
          json.id service_provider.id
          json.name service_provider.public_name
        end
      end
    end
    @provider_available = JbuilderTemplate.encode(view_context) do |json|
      json.array! @locations.each do |location|
        json.location location.id
        json.days Day.all do |day|
          json.day day.id
          json.resources ServiceProvider.joins(:provider_times).actives.where(provider_times: {day: day}).where(location: location).order(:order, :public_name).uniq do |provider|
            json.id provider.id
            json.name provider.public_name
          end
        end
      end
    end
    @bookings = Booking.where(service_provider_id: @service_providers)
    @booking = Booking.new
    @provider_break = ProviderBreak.new
    @payment = Payment.new

    @state = Hash.new
    @state[:local] = params[:local] if params[:local]
    @state[:provider] = params[:provider] if params[:provider]
    @state[:date] = params[:date] if params[:date]

    @timezone = CustomTimezone.from_company(@company)
  end

  def fixed_index
    @company = Company.find(current_user.company_id)
    @company_setting = @company.company_setting
    @use_identification_number = @company.company_setting.use_identification_number
    if current_user.role_id == Role.find_by_name("Staff").id || current_user.role_id == Role.find_by_name("Staff (sin edición)").id
      @locations = Location.where(:active => true, id: ServiceProvider.where(active: true, id: UserProvider.where(user_id: current_user.id).pluck(:service_provider_id)).pluck(:location_id)).accessible_by(current_ability).order(:order, :name)
    else
      @locations = Location.where(:active => true).accessible_by(current_ability).order(:order, :name)
    end
    @service_providers = ServiceProvider.where(location_id: @locations).order(:order, :public_name)
    @provider_groups = JbuilderTemplate.encode(view_context) do |json|
      json.array! ProviderGroup.where(company_id: current_user.company_id).order(:order, :name) do |provider_group|
        json.name  provider_group.name
        json.location_id provider_group.location_id
        json.resources provider_group.service_providers.where(active: true) do |service_provider|
          json.id service_provider.id
          json.name service_provider.public_name
        end
      end
    end
    @bookings = Booking.where(service_provider_id: @service_providers)
    @booking = Booking.new
    @provider_break = ProviderBreak.new
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
    u = @booking
    is_payed = false
    if (u.payed && !u.payed_booking.nil?)
      is_payed = true
    end

    sessions_ratio = "0/0"
    if u.is_session
      is_session = true
      session_index = 1
      if !u.session_booking_id.nil? && !u.session_booking.nil?
        Booking.where(:session_booking_id => u.session_booking.id, :is_session_booked => true).order('start asc').each do |b|
          if b.id == u.id
            break
          else
            session_index = session_index + 1
          end
        end
        sessions_ratio = "sesión " + session_index.to_s + " (de un total de " + u.session_booking.sessions_amount.to_s + ")"
      else
        sessions_ratio = "0/0"
      end
    else
      sessions_ratio = "0/0"
    end

    after_book_date = DateTime.now + u.service.company.company_setting.after_booking.months
    after_book_date = I18n.l after_book_date.to_date, format: :day

    @booking_json = { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :price => u.price, :status_id => u.status_id, :client_id => u.client.id, :first_name => u.client.first_name, :last_name => u.client.last_name, :email => u.client.email, :phone => u.client.phone, :identification_number => u.client.identification_number, :send_mail => u.send_mail, :provider_lock => u.provider_lock, :notes => u.notes,  :company_comment => u.company_comment, :service_provider_active => u.service_provider.active, :service_active => u.service.active, :service_provider_name => u.service_provider.public_name, :service_name => u.service.name, :address => u.client.address, :district => u.client.district, :city => u.client.city, :birth_day => u.client.birth_day, :birth_month => u.client.birth_month, :birth_year => u.client.birth_year, :age => u.client.age, :record => u.client.record, :second_phone => u.client.second_phone, :gender => u.client.gender, deal_code: @booking.deal.nil? ? nil : @booking.deal.code, :payed => is_payed, :is_session => u.is_session, :sessions_ratio => sessions_ratio, :location_id => u.location_id, :provider_preference => u.location.company.company_setting.provider_preference, :after_date => after_book_date, :after_booking => u.service.company.company_setting.after_booking, :session_booking_id => u.session_booking_id, :payed_state => u.payed_state, :payment_id => u.payment_id, :payed_booking_id => u.payed_booking_id, :custom_attributes => u.client.get_custom_attributes, :bundled => u.bundled}
    respond_to do |format|
      format.html { }
      format.json { render :json => @booking_json }
      format.pdf do
        pdf = BookingsPdf.new(@booking)
        send_data pdf.render, filename: 'Reserva ' + @booking.client.first_name + '_' + @booking.client.last_name + '_' + DateTime.now.to_date.to_s + '.pdf', type: 'application/pdf'
      end
    end
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
    if mobile_request?
      @company = current_user.company
      @date = DateTime.now
      if !params[:date].blank?
        @date = params[:date].to_time
      end
    end
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @bookings = []
    @errors = []

    @company = Company.find(current_user.company_id)
    @company_setting = @company.company_setting

    booking_group = nil
    if booking_buffer_params[:bookings].length > 1
      provider = booking_buffer_params[:bookings]['0']['service_provider_id']
      location = ServiceProvider.find(provider).location

      group = Booking.where(location: location).where.not(booking_group: nil).order(:booking_group).last
      if group.nil?
        booking_group = 0
      else
        booking_group = group.booking_group + 1
      end
    end

    session_booking = nil

    booking_buffer_params[:bookings].each do |pos, buffer_params|
      staff_code = nil
      new_booking_params = buffer_params.except(:client_first_name, :client_last_name, :client_phone, :client_email, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_record, :client_second_phone, :client_gender, :staff_code, :session_booking_id, :has_sessions)

      @booking = Booking.new(new_booking_params)

      if @booking.price.nil?
        @booking.price = 0
      end

      should_create_sessions = false
      if buffer_params[:session_booking_id]
        if buffer_params[:session_booking_id] != "0" && buffer_params[:session_booking_id] != 0
          session_booking = SessionBooking.find(buffer_params[:session_booking_id])
          #session_booking.sessions_taken = session_booking.sessions_taken + 1
          @booking = Booking.where(:session_booking_id => session_booking.id, :is_session_booked => false).first
          @booking.start = buffer_params[:start]
          @booking.end = buffer_params[:end]
          @booking.service_provider_id = buffer_params[:service_provider_id]
          @booking.session_booking_id = session_booking.id
          @booking.is_session = true
          @booking.is_session_booked = true
          @booking.payed_state = buffer_params[:payed_state]
          @booking.company_comment = buffer_params[:company_comment]
          @booking.notes = buffer_params[:notes]

          #Set list_price to it's service price
          if @booking.service.price != 0
            if !session_booking.sessions_amount.nil? && session_booking.sessions_amount != 0
              @booking.list_price = @booking.service.price / session_booking.sessions_amount
            elsif !@booking.service.sessions_amount.nil? && @booking.service.sessions_amount != 0
              @booking.list_price = @booking.service.price / @booking.service.sessions_amount
            else
              @booking.list_price = @booking.service.price
            end

            logger.debug "Debug 1"
          else
            @booking.list_price = 0
            @booking.price = 0
            logger.debug "Debug 2"
          end

          if @booking.price.nil?
            @booking.price = 0
            logger.debug "Debug 3"
          end

          #If price is not equivalent, then it has discount
          if @booking.price != @booking.list_price
            logger.debug "Debug 4"
            if @booking.list_price != 0
              logger.debug "Debug 5"
              @booking.discount = ((1 - @booking.price / @booking.list_price) * 100).round()
            else
              logger.debug "Debug 6"
              if @booking.price > 0
                logger.debug "Debug 7"
                @booking.list_price = @booking.price
              end
            end
          end

          if @booking.payed
            @booking.user_session_confirmed = false
          else
            @booking.user_session_confirmed = true
          end
        else
          should_create_sessions = true
          session_booking = SessionBooking.new
          #session_booking.sessions_taken = 1
          serv = Service.find(buffer_params[:service_id])
          session_booking.service_id = buffer_params[:service_id]
          session_booking.sessions_amount = serv.sessions_amount

        end
      else
        #Set list_price to it's service price
        @booking.list_price = @booking.service.price

        if @booking.list_price.nil?
          @booking.list_price = 0
        end
        if @booking.price.nil?
          @booking.price = 0
        end

        #If price is not equivalent, then it has discount
        if @booking.price != @booking.list_price
          if @booking.list_price != 0
            @booking.discount = ((1 - @booking.price / @booking.list_price) * 100).round()
          else
            if @booking.price > 0
              @booking.list_price = @booking.price
            end
          end
        end
      end

      if @company_setting.staff_code
        if !buffer_params[:staff_code].blank? && StaffCode.where(company_id: current_user.company_id, code: buffer_params[:staff_code], active: true).count > 0
          staff_code = StaffCode.where(company_id: current_user.company_id, code: buffer_params[:staff_code], active: true).first.id
        else
          @errors << {
            :booking => pos,
            :errors => ["El código de empleado ingresado no es correcto."]
          }
          next
        end
      end

      if @company_setting.client_exclusive
        if !buffer_params[:client_id].blank? && !buffer_params[:client_identification_number].blank?
          @client = Client.find(buffer_params[:client_id])
          @client.identification_number = buffer_params[:client_identification_number]
          @client.first_name = buffer_params[:client_first_name]
          @client.last_name = buffer_params[:client_last_name]
          @client.email = buffer_params[:client_email]
          @client.phone = buffer_params[:client_phone]
          @client.address = buffer_params[:client_address]
          @client.district = buffer_params[:client_district]
          @client.city = buffer_params[:client_city]
          @client.birth_day = buffer_params[:client_birth_day]
          @client.birth_month = buffer_params[:client_birth_month]
          @client.birth_year = buffer_params[:client_birth_year]
          @client.age = buffer_params[:client_age]
          @client.record = buffer_params[:client_record]
          @client.second_phone = buffer_params[:client_second_phone]
          @client.gender = buffer_params[:client_gender]
          @client.save
          @client.save_attributes(params[:custom_attributes])
          if User.find_by_email(@client.email)
            new_booking_params[:user_id] = User.find_by_email(@client.email).id
          end
        else
          @errors << {
            :booking => pos,
            :errors => ["El cliente no está registrado o no puede reservar."]
          }
          next
        end
      else
        if !buffer_params[:client_id].blank?
          @client = Client.find(buffer_params[:client_id])
          @client.identification_number = buffer_params[:client_identification_number]
          @client.first_name = buffer_params[:client_first_name]
          @client.last_name = buffer_params[:client_last_name]
          @client.email = buffer_params[:client_email]
          @client.phone = buffer_params[:client_phone]
          @client.address = buffer_params[:client_address]
          @client.district = buffer_params[:client_district]
          @client.city = buffer_params[:client_city]
          @client.birth_day = buffer_params[:client_birth_day]
          @client.birth_month = buffer_params[:client_birth_month]
          @client.birth_year = buffer_params[:client_birth_year]
          @client.age = buffer_params[:client_age]
          @client.record = buffer_params[:client_record]
          @client.second_phone = buffer_params[:client_second_phone]
          @client.gender = buffer_params[:client_gender]
          if @client.save
            if !params[:custom_attributes].blank?
              @client.save_attributes(params[:custom_attributes])
            end
            if User.find_by_email(@client.email)
              new_booking_params[:user_id] = User.find_by_email(@client.email).id
            end
          else
            @errors << {
              :booking => pos,
              :errors => ["El cliente no se pudo guardar: " + @client.errors.full_messages.inspect]
            }
          end
        else
          if !buffer_params[:client_email].nil?
            if buffer_params[:client_email].empty?
              if Client.where(email: '', company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => buffer_params[:client_first_name]+' '+buffer_params[:client_last_name]).count > 0
                client = Client.where(email: '', company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => buffer_params[:client_first_name]+' '+buffer_params[:client_last_name]).first
                client.save_attributes(params[:custom_attributes])
                @booking.client = client
              else
                client = Client.new(email: buffer_params[:client_email], identification_number: buffer_params[:client_identification_number], first_name: buffer_params[:client_first_name], last_name: buffer_params[:client_last_name], phone: buffer_params[:client_phone], address: buffer_params[:client_address], district: buffer_params[:client_district], city: buffer_params[:client_city], birth_day: buffer_params[:client_birth_day], birth_month: buffer_params[:client_birth_month], birth_year: buffer_params[:client_birth_year], age: buffer_params[:client_age], record: buffer_params[:client_record], second_phone: buffer_params[:client_second_phone], gender: buffer_params[:client_gender], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id)
                if client.save
                  client.save_attributes(params[:custom_attributes])
                  @booking.client = client
                else
                  @errors << {
                    :booking => pos,
                    :errors => ["El cliente no se pudo guardar: " + client.errors.full_messages.inspect]
                  }
                end
              end
            else
              if Client.where(email: buffer_params[:client_email], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).count > 0
                client = Client.where(email: buffer_params[:client_email], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).first
                client.save_attributes(params[:custom_attributes])
                @booking.client = client
              else
                client = Client.new(email: buffer_params[:client_email], identification_number: buffer_params[:client_identification_number], first_name: buffer_params[:client_first_name], last_name: buffer_params[:client_last_name], phone: buffer_params[:client_phone], address: buffer_params[:client_address], district: buffer_params[:client_district], city: buffer_params[:client_city], birth_day: buffer_params[:client_birth_day], birth_month: buffer_params[:client_birth_month], birth_year: buffer_params[:client_birth_year], age: buffer_params[:client_age], record: buffer_params[:client_record], second_phone: buffer_params[:client_second_phone], gender: buffer_params[:client_gender], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id)
                if client.save
                  client.save_attributes(params[:custom_attributes])
                  @booking.client = client
                else
                  @errors << {
                    :booking => pos,
                    :errors => ["El cliente no se pudo guardar: " + client.errors.full_messages.inspect]
                  }
                end
              end
            end
            if User.find_by_email(buffer_params[:client_email])
              new_booking_params[:user_id] = User.find_by_email(buffer_params[:client_email]).id
            end
          end
        end
      end

      @booking.max_changes = @company_setting.max_changes
      @booking.booking_group = booking_group

      if @booking && @booking.service_provider
        @booking.location = @booking.service_provider.location
      end

      # If it's a sessions service and it's the first session, save client and user for SessionBooking
      # and associate it with the @booking
      sessions_ratio = ""
      if should_create_sessions

        session_booking.client_id = @booking.client_id
        if buffer_params[:client_email] && buffer_params[:client_email] != ""
          if User.find_by_email(buffer_params[:client_email])
            session_booking.user_id = User.find_by_email(buffer_params[:client_email]).id
          end
        end

        session_booking.save
        @booking.session_booking_id = session_booking.id
        @booking.is_session = true
        @booking.is_session_booked = true
        if @booking.payed
          @booking.user_session_confirmed = false
        else
          @booking.user_session_confirmed = true
        end

        if @booking.service.price != 0
            @booking.list_price = @booking.service.price / @booking.service.sessions_amount
            logger.debug "Debug 1"
        else
          @booking.list_price = 0
          @booking.price = 0
          logger.debug "Debug 2"
        end

        if @booking.price.nil?
          @booking.price = 0
          logger.debug "Debug 3"
        end

        #If price is not equivalent, then it has discount
        if @booking.price != @booking.list_price
          logger.debug "Debug 4"
          if @booking.list_price != 0
            logger.debug "Debug 5"
            @booking.discount = ((1 - @booking.price / @booking.list_price) * 100).round()
          else
            logger.debug "Debug 6"
            if @booking.price > 0
              logger.debug "Debug 7"
              @booking.list_price = @booking.price
            end
          end
        end

      end

      if @booking.is_session && !@booking.payment_id.nil?
        @booking.payed_state = true
      end

      if !buffer_params[:status_id].blank?
        @booking.status_id = buffer_params[:status_id]
      end
      if @booking.save

        #If it's a sessions service and it's the first session, create the others.
        #Ele if it's an existing session, just save the SessionBooking
        if should_create_sessions

          if !session_booking.nil?
            sessions_missing = session_booking.sessions_amount - 1
            sessions_ratio = "Sesión 1 de " + @booking.service.sessions_amount.to_s

            for i in 0..sessions_missing-1
              new_booking = @booking.dup
              new_booking.is_session = true
              new_booking.is_session_booked = false
              new_booking.user_session_confirmed = false
              new_booking.session_booking_id = session_booking.id

              if new_booking.service.price != 0
                  new_booking.list_price = new_booking.service.price / new_booking.service.sessions_amount
                  logger.debug "Debug 1"
              else
                new_booking.list_price = 0
                new_booking.price = 0
                logger.debug "Debug 2"
              end

              if new_booking.price.nil?
                new_booking.price = 0
                logger.debug "Debug 3"
              end

              #If price is not equivalent, then it has discount
              if new_booking.price != new_booking.list_price
                logger.debug "Debug 4"
                if new_booking.list_price != 0
                  logger.debug "Debug 5"
                  new_booking.discount = ((1 - new_booking.price / new_booking.list_price) * 100).round()
                else
                  logger.debug "Debug 6"
                  if new_booking.price > 0
                    logger.debug "Debug 7"
                    new_booking.list_price = @booking.price
                  end
                end
              end

              new_booking.save
            end
          end

        elsif !session_booking.nil?
          session_booking.save

          session_index = 1
          Booking.where(:session_booking_id => session_booking.id, :is_session_booked => true).order('start asc').each do |b|
            if b.id == @booking.id
              break
            else
              session_index = session_index + 1
            end
          end

          sessions_ratio = "Sesión " + session_index.to_s + " de " + session_booking.sessions_amount.to_s

        end

        u = @booking
        if u.warnings then warnings = u.warnings.full_messages else warnings = [] end

        prepayed = "No"
        if @booking.payed
          prepayed = "Sí"
        end

        @bookings << {
          :id => u.id,
          :start => u.start,
          :end => u.end,
          :service_id => u.service_id,
          :service_provider_id => u.service_provider_id,
          :status_id => u.status_id,
          :first_name => u.client.first_name,
          :last_name => u.client.last_name,
          :email => u.client.email,
          :phone => u.client.phone,
          :notes => u.notes,
          :company_comment => u.company_comment,
          :provider_lock => u.provider_lock,
          :service_name => u.service.name,
          :warnings => warnings,
          :prepayed => prepayed,
          :is_session => u.is_session,
          :is_session_booked => u.is_session_booked,
          :user_session_confirmed => u.user_session_confirmed,
          :sessions_ratio => sessions_ratio,
          :payed_state => u.payed_state,
          :bundled => u.bundled,
          :location_id => u.location_id
        }

        BookingHistory.create(booking_id: @booking.id, action: "Creada por Calendario", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: current_user.id, staff_code_id: staff_code, notes: @booking.notes, company_comment: @booking.company_comment)
      else
        @errors << {
            :booking => pos,
            :errors => @booking.errors.full_messages
          }
      end
    end
    respond_to do |format|
      if @errors.length == 0

        if @bookings.length > 1 && session_booking.nil?
          Booking.send_multiple_booking_mail(@booking.location_id, booking_group)
        end

        if !session_booking.nil?
          if @booking.user_session_confirmed && @booking.send_mail
            session_booking.send_sessions_booking_mail
          else
            if @booking.payed && @booking.send_mail
              @booking.send_admin_payed_session_mail
            else
              #Send anyways, it needs validation
              @booking.send_validate_mail
            end
          end
        end

        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => @bookings }
        format.js { }
      else
        @bookings.each do |book|
          Booking.find(book[:id]).destroy
        end

        format.html { render action: 'new' }
        format.json { render :json => { :errors => @errors }, :status => 422 }
        format.js { }
      end
    end
  end

  # POST /force_create
  # POST /force_create.json
  def force_create
    @bookings = []
    @errors = []

    @company = Company.find(current_user.company_id)
    @company_setting = @company.company_setting

    booking_group = nil
    if booking_buffer_params[:bookings].length > 1
      provider = booking_buffer_params[:bookings]['0']['service_provider_id']
      location = ServiceProvider.find(provider).location

      group = Booking.where(location: location).where.not(booking_group: nil).order(:booking_group).last
      if group.nil?
        booking_group = 0
      else
        booking_group = group.booking_group + 1
      end
    end

    session_booking = nil

    booking_buffer_params[:bookings].each do |pos, buffer_params|
      staff_code = nil
      new_booking_params = buffer_params.except(:client_first_name, :client_last_name, :client_phone, :client_email, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_record, :client_second_phone, :client_gender, :staff_code)
      @booking = Booking.new(new_booking_params)

      if @booking.price.nil?
        @booking.price = 0
      end

      should_create_sessions = false
      if buffer_params[:session_booking_id]
        if buffer_params[:session_booking_id] != "0" && buffer_params[:session_booking_id] != 0
          session_booking = SessionBooking.find(buffer_params[:session_booking_id])
          #session_booking.sessions_taken = session_booking.sessions_taken + 1
          @booking = Booking.where(:session_booking_id => session_booking.id, :is_session_booked => false).first
          @booking.start = buffer_params[:start]
          @booking.end = buffer_params[:end]
          @booking.service_provider_id = buffer_params[:service_provider_id]
          @booking.session_booking_id = session_booking.id
          @booking.is_session = true
          @booking.is_session_booked = true

          #Set list_price to it's service price
          if @booking.service.price != 0
            @booking.list_price = @booking.service.price / @booking.service.sessions_amount
          else
            @booking.list_price = 0
            @booking.price = 0
          end

          if @booking.price.nil?
            @booking.price = 0
          end

          #If price is not equivalent, then it has discount
          if @booking.price != @booking.list_price
            if @booking.list_price != 0
              @booking.discount = ((1 - @booking.price / @booking.list_price) * 100).round()
            else
              if @booking.price > 0
                @booking.list_price = @booking.price
              end
            end
          end

          if @booking.payed
            @booking.user_session_confirmed = false
          else
            @booking.user_session_confirmed = true
          end
        else
          should_create_sessions = true
          session_booking = SessionBooking.new
          #session_booking.sessions_taken = 1
          serv = Service.find(buffer_params[:service_id])
          session_booking.service_id = buffer_params[:service_id]
          session_booking.sessions_amount = serv.sessions_amount
        end
      else
        #Set list_price to it's service price
        @booking.list_price = @booking.service.price

        if @booking.list_price.nil?
          @booking.list_price = 0
        end
        if @booking.price.nil?
          @booking.price = 0
        end

        #If price is not equivalent, then it has discount
        if @booking.price != @booking.list_price
          if @booking.list_price != 0
            @booking.discount = ((1 - @booking.price / @booking.list_price) * 100).round()
          else
            if @booking.price > 0
              @booking.list_price = @booking.price
            end
          end
        end
      end

      if @company_setting.staff_code
        if !buffer_params[:staff_code].blank? && StaffCode.where(company_id: current_user.company_id, code: buffer_params[:staff_code], active: true).count > 0
          staff_code = StaffCode.where(company_id: current_user.company_id, code: buffer_params[:staff_code], active: true).first.id
        else
          @errors << {
            :booking => pos,
            :errors => ["El código de empleado ingresado no es correcto."]
          }
          next
        end
      end

      if @company_setting.client_exclusive
        if !buffer_params[:client_id].blank? && !buffer_params[:client_identification_number].blank?
          @client = Client.find(buffer_params[:client_id])
          @client.identification_number = buffer_params[:client_identification_number]
          @client.first_name = buffer_params[:client_first_name]
          @client.last_name = buffer_params[:client_last_name]
          @client.email = buffer_params[:client_email]
          @client.phone = buffer_params[:client_phone]
          @client.address = buffer_params[:client_address]
          @client.district = buffer_params[:client_district]
          @client.city = buffer_params[:client_city]
          @client.birth_day = buffer_params[:client_birth_day]
          @client.birth_month = buffer_params[:client_birth_month]
          @client.birth_year = buffer_params[:client_birth_year]
          @client.age = buffer_params[:client_age]
          @client.record = buffer_params[:client_record]
          @client.second_phone = buffer_params[:client_second_phone]
          @client.gender = buffer_params[:client_gender]
          if @client.save
            if User.find_by_email(@client.email)
              new_booking_params[:user_id] = User.find_by_email(@client.email).id
            end
          else
            @errors << {
              :booking => pos,
              :errors => ["El cliente no se pudo guardar: " + @client.errors.full_messages.inspect]
            }
          end
        else
          @errors << {
            :booking => pos,
            :errors => ["El cliente no está registrado o no puede reservar."]
          }
          next
        end
      else
        if !buffer_params[:client_id].blank?
          @client = Client.find(buffer_params[:client_id])
          @client.identification_number = buffer_params[:client_identification_number]
          @client.first_name = buffer_params[:client_first_name]
          @client.last_name = buffer_params[:client_last_name]
          @client.email = buffer_params[:client_email]
          @client.phone = buffer_params[:client_phone]
          @client.address = buffer_params[:client_address]
          @client.district = buffer_params[:client_district]
          @client.city = buffer_params[:client_city]
          @client.birth_day = buffer_params[:client_birth_day]
          @client.birth_month = buffer_params[:client_birth_month]
          @client.birth_year = buffer_params[:client_birth_year]
          @client.age = buffer_params[:client_age]
          @client.record = buffer_params[:client_record]
          @client.second_phone = buffer_params[:client_second_phone]
          @client.gender = buffer_params[:client_gender]
          if @client.save
            if User.find_by_email(@client.email)
              new_booking_params[:user_id] = User.find_by_email(@client.email).id
            end
          else
            @errors << {
              :booking => pos,
              :errors => ["El cliente no se pudo guardar: " + @client.errors.full_messages.inspect]
            }
          end
        else
          if !buffer_params[:client_email].nil?
            if buffer_params[:client_email].empty?
              if Client.where(email: '', company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => buffer_params[:client_first_name]+' '+buffer_params[:client_last_name]).count > 0
                client = Client.where(email: '', company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => buffer_params[:client_first_name]+' '+buffer_params[:client_last_name]).first
                @booking.client = client
              else
                client = Client.new(email: buffer_params[:client_email], identification_number: buffer_params[:client_identification_number], first_name: buffer_params[:client_first_name], last_name: buffer_params[:client_last_name], phone: buffer_params[:client_phone], address: buffer_params[:client_address], district: buffer_params[:client_district], city: buffer_params[:client_city], birth_day: buffer_params[:client_birth_day], birth_month: buffer_params[:client_birth_month], birth_year: buffer_params[:client_birth_year], age: buffer_params[:client_age], record: buffer_params[:client_record], second_phone: buffer_params[:client_second_phone], gender: buffer_params[:client_gender], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id)
                if client.save
                  @booking.client = client
                else
                  @errors << {
                    :booking => pos,
                    :errors => ["El cliente no se pudo guardar: " + client.errors.full_messages.inspect]
                  }
                end
              end
            else
              if Client.where(email: buffer_params[:client_email], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).count > 0
                client = Client.where(email: buffer_params[:client_email], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).first
                @booking.client = client
              else
                client = Client.new(email: buffer_params[:client_email], identification_number: buffer_params[:client_identification_number], first_name: buffer_params[:client_first_name], last_name: buffer_params[:client_last_name], phone: buffer_params[:client_phone], address: buffer_params[:client_address], district: buffer_params[:client_district], city: buffer_params[:client_city], birth_day: buffer_params[:client_birth_day], birth_month: buffer_params[:client_birth_month], birth_year: buffer_params[:client_birth_year], age: buffer_params[:client_age], record: buffer_params[:client_record], second_phone: buffer_params[:client_second_phone], gender: buffer_params[:client_gender], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id)
                if client.save
                  @booking.client = client
                else
                  @errors << {
                    :booking => pos,
                    :errors => ["El cliente no se pudo guardar: " + client.errors.full_messages.inspect]
                  }
                end
              end
            end
            if User.find_by_email(buffer_params[:client_email])
              new_booking_params[:user_id] = User.find_by_email(buffer_params[:client_email]).id
            end
          end
        end
      end

      @booking.max_changes = @company_setting.max_changes
      @booking.booking_group = booking_group

      if @booking && @booking.service_provider
        @booking.location = @booking.service_provider.location
      end


      sessions_ratio = ""

      if should_create_sessions

        session_booking_index = 1

        session_booking.client_id = @booking.client_id
        if User.find_by_email(buffer_params[:client_email])
          session_booking.user_id = User.find_by_email(buffer_params[:client_email]).id
        end

        session_booking.save
        @booking.session_booking_id = session_booking.id
        @booking.is_session = true
        @booking.is_session_booked = true
        if @booking.payed
          @booking.user_session_confirmed = false
        else
          @booking.user_session_confirmed = true
        end

        if @booking.service.price != 0
            @booking.list_price = @booking.service.price / @booking.service.sessions_amount
            logger.debug "Debug 1"
        else
          @booking.list_price = 0
          @booking.price = 0
          logger.debug "Debug 2"
        end

        if @booking.price.nil?
          @booking.price = 0
          logger.debug "Debug 3"
        end

        #If price is not equivalent, then it has discount
        if @booking.price != @booking.list_price
          logger.debug "Debug 4"
          if @booking.list_price != 0
            logger.debug "Debug 5"
            @booking.discount = ((1 - @booking.price / @booking.list_price) * 100).round()
          else
            logger.debug "Debug 6"
            if @booking.price > 0
              logger.debug "Debug 7"
              @booking.list_price = @booking.price
            end
          end
        end

      end

      if !buffer_params[:status_id].blank?
        @booking.status_id = buffer_params[:status_id]
      end
      if @booking.save


        if should_create_sessions

          sessions_missing = session_booking.sessions_amount - 1
          sessions_ratio = "Sesión 1 de " + @booking.service.sessions_amount.to_s

          for i in 0..sessions_missing-1
            new_booking = @booking.dup
            new_booking.is_session = true
            new_booking.is_session_booked = false
            new_booking.user_session_confirmed = false
            new_booking.session_booking_id = session_booking.id

            if new_booking.service.price != 0
                new_booking.list_price = new_booking.service.price / new_booking.service.sessions_amount
                logger.debug "Debug 1"
            else
              new_booking.list_price = 0
              new_booking.price = 0
              logger.debug "Debug 2"
            end

            if new_booking.price.nil?
              new_booking.price = 0
              logger.debug "Debug 3"
            end

            #If price is not equivalent, then it has discount
            if new_booking.price != new_booking.list_price
              logger.debug "Debug 4"
              if new_booking.list_price != 0
                logger.debug "Debug 5"
                new_booking.discount = ((1 - new_booking.price / new_booking.list_price) * 100).round()
              else
                logger.debug "Debug 6"
                if new_booking.price > 0
                  logger.debug "Debug 7"
                  new_booking.list_price = @booking.price
                end
              end
            end

            new_booking.save
          end

        elsif !session_booking.nil?
          session_booking.save

          session_index = 1
          Booking.where(:session_booking_id => session_booking.id, :is_session_booked => true).order('start asc').each do |b|
            if b.id == @booking.id
              break
            else
              session_index = session_index + 1
            end
          end

          sessions_ratio = "Sesión " + session_index.to_s + " de " + session_booking.sessions_amount.to_s

        end


        u = @booking
        if u.warnings then warnings = u.warnings.full_messages else warnings = [] end
          prepayed = "No"
          if @booking.payed
            prepayed = "Sí"
          end
        @bookings << {
          :id => u.id,
          :start => u.start,
          :end => u.end,
          :service_id => u.service_id,
          :service_provider_id => u.service_provider_id,
          :status_id => u.status_id,
          :first_name => u.client.first_name,
          :last_name => u.client.last_name,
          :email => u.client.email,
          :phone => u.client.phone,
          :notes => u.notes,
          :company_comment => u.company_comment,
          :provider_lock => u.provider_lock,
          :service_name => u.service.name,
          :warnings => warnings,
          :prepayed => prepayed,
          :is_session => u.is_session,
          :is_session_booked => u.is_session_booked,
          :user_session_confirmed => u.user_session_confirmed,
          :sessions_ratio => sessions_ratio,
          :payed_state => u.payed_state,
          :bundled => u.bundled
        }

        BookingHistory.create(booking_id: @booking.id, action: "Creada por Calendario", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: current_user.id, staff_code_id: staff_code, notes: @booking.notes, company_comment: @booking.company_comment)
      else
        @errors << {
            :booking => pos,
            :errors => @booking.errors.full_messages
          }
      end
    end
    respond_to do |format|

      if @bookings.length > 1 && session_booking.nil?
        Booking.send_multiple_booking_mail(@booking.location_id, booking_group)
      end

      if !session_booking.nil?
        if @booking.user_session_confirmed
          session_booking.send_sessions_booking_mail
        else
          if @booking.payed
            @booking.send_admin_payed_session_mail
          else
            @booking.send_validate_mail
          end
        end
      end

      format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
      format.json { render :json => @bookings }
      format.js { }
    end
  end

  def booking_valid
    @company = Company.find(current_user.company_id)
    @company_setting = @company.company_setting
    staff_code = nil
    new_booking_params = booking_params.except(:client_first_name, :client_last_name, :client_phone, :client_email, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_record, :client_second_phone, :client_record, :client_second_phone, :client_gender, :staff_code, :deal_code)
    if @company_setting.staff_code
      if booking_params[:staff_code] && !booking_params[:staff_code].empty? && StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code], active: true).count > 0
        staff_code = StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code], active: true).first.id
      else
        render :json => { :errors => ["El código de empleado ingresado no es correcto."] }, :status => 422
        return
      end
    end
    if @company_setting.deal_activate
      if booking_params[:deal_code] && !booking_params[:deal_code].empty?
        if @company_setting.deal_exclusive
          if Deal.where(company_id: current_user.company_id, code: booking_params[:deal_code]).count > 0
            deal_code = Deal.where(company_id: current_user.company_id, code: booking_params[:deal_code]).first.id
            new_booking_params[:deal_id] = deal_code
          else
            render :json => { :errors => ["El código de convenio ingresado no es correcto."] }, :status => 422
            return
          end
        else
          if Deal.where(company_id: current_user.company_id, code: booking_params[:deal_code]).count > 0
            deal_code = Deal.where(company_id: current_user.company_id, code: booking_params[:deal_code]).first.id
            new_booking_params[:deal_id] = deal_code
          else
            deal_code = Deal.create(company_id: current_user.company_id, code: booking_params[:deal_code], quantity: @company_setting.deal_quantity, constraint_option: @company_setting.deal_constraint_quantity, constraint_quantity: @company_setting.deal_constraint_quantity)
            new_booking_params[:deal_id] = deal_code.id
          end
        end
      else
        if @company_setting.deal_required
          render :json => { :errors => ["El código de convenio debe ser ingresado."] }, :status => 422
          return
        else
          deal_code = nil
          new_booking_params[:deal_id] = nil
        end
      end
    end
    @booking = Booking.new(new_booking_params)
    if @company_setting.client_exclusive
      if !booking_params[:client_id].nil? && !booking_params[:client_id].empty? && !booking_params[:client_identification_number].empty?
        @client = Client.find(booking_params[:client_id])
        @client.identification_number = booking_params[:client_identification_number]
        @client.first_name = booking_params[:client_first_name]
        @client.last_name = booking_params[:client_last_name]
        @client.email = booking_params[:client_email]
        @client.phone = booking_params[:client_phone]
        @client.address = booking_params[:client_address]
        @client.district = booking_params[:client_district]
        @client.city = booking_params[:client_city]
        @client.birth_day = booking_params[:client_birth_day]
        @client.birth_month = booking_params[:client_birth_month]
        @client.birth_year = booking_params[:client_birth_year]
        @client.age = booking_params[:client_age]
        @client.record = booking_params[:client_record]
        @client.second_phone = booking_params[:client_second_phone]
        @client.gender = booking_params[:client_gender]
        if @client.save
          if User.find_by_email(@client.email)
            new_booking_params[:user_id] = User.find_by_email(@client.email).id
          end
        else
          render :json => { :errors => ["El cliente no se pudo guardar: " + @client.errors.full_messages.inspect] }, :status => 422
          return
        end
      else
        render :json => { :errors => ["El cliente no está registrado o no puede reservar."] }, :status => 422
        return
      end
    else
      if !booking_params[:client_id].nil? && !booking_params[:client_id].empty?
        @client = Client.find(booking_params[:client_id])
        @client.identification_number = booking_params[:client_identification_number]
        @client.first_name = booking_params[:client_first_name]
        @client.last_name = booking_params[:client_last_name]
        @client.email = booking_params[:client_email]
        @client.phone = booking_params[:client_phone]
        @client.address = booking_params[:client_address]
        @client.district = booking_params[:client_district]
        @client.city = booking_params[:client_city]
        @client.birth_day = booking_params[:client_birth_day]
        @client.birth_month = booking_params[:client_birth_month]
        @client.birth_year = booking_params[:client_birth_year]
        @client.age = booking_params[:client_age]
        @client.record = booking_params[:client_record]
        @client.second_phone = booking_params[:client_second_phone]
        @client.gender = booking_params[:client_gender]
        if @client.save
          if User.find_by_email(@client.email)
            new_booking_params[:user_id] = User.find_by_email(@client.email).id
          end
        else
          render :json => { :errors => ["El cliente no se pudo guardar: " + @client.errors.full_messages.inspect] }, :status => 422
          return
        end
      else
        if !booking_params[:client_email].nil?
          if booking_params[:client_email].empty?
            if Client.where(email: '', company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => booking_params[:client_first_name]+' '+booking_params[:client_last_name]).count > 0
              client = Client.where(email: '', company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => booking_params[:client_first_name]+' '+booking_params[:client_last_name]).first
              @booking.client = client
            else
              client = Client.new(email: booking_params[:client_email], identification_number: booking_params[:client_identification_number], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], address: booking_params[:client_address], district: booking_params[:client_district], city: booking_params[:client_city], birth_day: booking_params[:client_birth_day], birth_month: booking_params[:client_birth_month], birth_year: booking_params[:client_birth_year], age: booking_params[:client_age], record: booking_params[:client_record], second_phone: booking_params[:client_second_phone], gender: booking_params[:client_gender], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
              if client.save
                @booking.client = client
              else
                render :json => { :errors => ["El cliente no se pudo guardar: " + client.errors.full_messages.inspect] }, :status => 422
                return
              end
            end
          else
            if Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).count > 0
              client = Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).first
              @booking.client = client
            else
              client = Client.new(email: booking_params[:client_email], identification_number: booking_params[:client_identification_number], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], address: booking_params[:client_address], district: booking_params[:client_district], city: booking_params[:client_city], birth_day: booking_params[:client_birth_day], birth_month: booking_params[:client_birth_month], birth_year: booking_params[:client_birth_year], age: booking_params[:client_age], record: booking_params[:client_record], second_phone: booking_params[:client_second_phone], gender: booking_params[:client_gender], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
              if client.save
                @booking.client = client
              else
                render :json => { :errors => ["El cliente no se pudo guardar: " + client.errors.full_messages.inspect] }, :status => 422
                return
              end
            end
          end
        end
      end
    end
    @booking.max_changes = @company_setting.max_changes
    if @booking && @booking.service_provider
      @booking.location = @booking.service_provider.location
    end
    respond_to do |format|
      if @booking.valid?
        u = @booking
        if u.warnings then warnings = u.warnings.full_messages else warnings = [] end
        @booking_json = { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :status_id => u.status_id, :first_name => u.client.first_name, :last_name => u.client.last_name, :email => u.client.email, :phone => u.client.phone, :notes => u.notes,  :company_comment => u.company_comment, :provider_lock => u.provider_lock, :service_name => u.service.name, :warnings => warnings }
        BookingHistory.create(booking_id: @booking.id, action: "Creada por Calendario", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: current_user.id, staff_code_id: staff_code, notes: @booking.notes, company_comment: @booking.company_comment)
        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => @booking_json }
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
    @company = Company.find(current_user.company_id)
    @company_setting = @company.company_setting
    staff_code = nil
    new_booking_params = booking_params.except(:client_first_name, :client_last_name, :client_phone, :client_email, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_record, :client_second_phone, :client_gender, :staff_code, :deal_code)
    if @company_setting.staff_code
      if booking_params[:staff_code] && !booking_params[:staff_code].empty? && StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code], active: true).count > 0
        staff_code = StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code], active: true).first.id
      else
        render :json => { :errors => ["El código de empleado ingresado no es correcto."] }, :status => 422
        return
      end
    end
    if @company_setting.deal_activate
      if booking_params[:deal_code] && !booking_params[:deal_code].empty?
        if @company_setting.deal_exclusive
          if Deal.where(company_id: current_user.company_id, code: booking_params[:deal_code]).count > 0
            deal_code = Deal.where(company_id: current_user.company_id, code: booking_params[:deal_code]).first.id
            new_booking_params[:deal_id] = deal_code
          else
            render :json => { :errors => ["El código de convenio ingresado no es correcto."] }, :status => 422
            return
          end
        else
          if Deal.where(company_id: current_user.company_id, code: booking_params[:deal_code]).count > 0
            deal_code = Deal.where(company_id: current_user.company_id, code: booking_params[:deal_code]).first.id
            new_booking_params[:deal_id] = deal_code
          else
            deal_code = Deal.create(company_id: current_user.company_id, code: booking_params[:deal_code], quantity: @company_setting.deal_quantity, constraint_option: @company_setting.deal_constraint_quantity, constraint_quantity: @company_setting.deal_constraint_quantity)
            new_booking_params[:deal_id] = deal_code.id
          end
        end
      else
        if @company_setting.deal_required
          render :json => { :errors => ["El código de convenio debe ser ingresado."] }, :status => 422
          return
        else
          deal_code = nil
          new_booking_params[:deal_id] = nil
        end
      end
    end
    if @company_setting.client_exclusive
      if !booking_params[:client_id].nil? && !booking_params[:client_id].empty? && !booking_params[:client_identification_number].empty?
        @client = Client.find(booking_params[:client_id])
        @client.identification_number = booking_params[:client_identification_number]
        @client.first_name = booking_params[:client_first_name]
        @client.last_name = booking_params[:client_last_name]
        @client.email = booking_params[:client_email]
        @client.phone = booking_params[:client_phone]
        @client.address = booking_params[:client_address]
        @client.district = booking_params[:client_district]
        @client.city = booking_params[:client_city]
        @client.birth_day = booking_params[:client_birth_day]
        @client.birth_month = booking_params[:client_birth_month]
        @client.birth_year = booking_params[:client_birth_year]
        @client.age = booking_params[:client_age]
        @client.record = booking_params[:client_record]
        @client.second_phone = booking_params[:client_second_phone]
        @client.gender = booking_params[:client_gender]
        if @client.save
          if User.find_by_email(@client.email)
            new_booking_params[:user_id] = User.find_by_email(@client.email).id
            @client.save_attributes(params[:custom_attributes])
          end
        else
          render :json => { :errors => ["El cliente no se pudo guardar: " + @client.errors.full_messages.inspect] }, :status => 422
          return
        end
      elsif !booking_params[:client_id].nil? && booking_params[:client_id].empty?
        render :json => { :errors => ["El cliente no está registrado o no puede reservar."] }, :status => 422
        return
      end
    else
      if !booking_params[:client_id].nil? && !booking_params[:client_id].empty?
        @client = Client.find(booking_params[:client_id])
        @client.identification_number = booking_params[:client_identification_number]
        @client.first_name = booking_params[:client_first_name]
        @client.last_name = booking_params[:client_last_name]
        @client.email = booking_params[:client_email]
        @client.phone = booking_params[:client_phone]
        @client.address = booking_params[:client_address]
        @client.district = booking_params[:client_district]
        @client.city = booking_params[:client_city]
        @client.birth_day = booking_params[:client_birth_day]
        @client.birth_month = booking_params[:client_birth_month]
        @client.birth_year = booking_params[:client_birth_year]
        @client.age = booking_params[:client_age]
        @client.record = booking_params[:client_record]
        @client.second_phone = booking_params[:client_second_phone]
        @client.gender = booking_params[:client_gender]
        if @client.save
          if User.find_by_email(booking_params[:client_email])
            new_booking_params[:user_id] = User.find_by_email(booking_params[:client_email]).id
            @client.save_attributes(params[:custom_attributes])
          end
        else
          render :json => { :errors => ["El cliente no se pudo guardar: " + @client.errors.full_messages.inspect] }, :status => 422
          return
        end
      else
        if !booking_params[:client_email].nil?
          if booking_params[:client_email].empty?
            if Client.where(email: '', company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => booking_params[:client_first_name]+' '+booking_params[:client_last_name]).count > 0
              client = Client.where(email: '', company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => booking_params[:client_first_name]+' '+booking_params[:client_last_name]).first
              new_booking_params[:client_id] = client.id
            else
              client = Client.new(email: booking_params[:client_email], identification_number: booking_params[:client_identification_number], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], address: booking_params[:client_address], district: booking_params[:client_district], city: booking_params[:client_city], birth_day: booking_params[:client_birth_day], birth_month: booking_params[:client_birth_month], birth_year: booking_params[:client_birth_year], age: booking_params[:client_age], record: booking_params[:client_record], second_phone: booking_params[:client_second_phone], gender: booking_params[:client_gender], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
              if client.save
                new_booking_params[:client_id] = client.id
                client.save_attributes(params[:custom_attributes])
              else
                render :json => { :errors => ["El cliente no se pudo guardar: " + client.errors.full_messages.inspect] }, :status => 422
                return
              end
            end
          else
            if Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).count > 0
              client = Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).first
              new_booking_params[:client_id] = client.id
            else
              client = Client.new(email: booking_params[:client_email], identification_number: booking_params[:client_identification_number], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], address: booking_params[:client_address], district: booking_params[:client_district], city: booking_params[:client_city], birth_day: booking_params[:client_birth_day], birth_month: booking_params[:client_birth_month], birth_year: booking_params[:client_birth_year], age: booking_params[:client_age], record: booking_params[:client_record], second_phone: booking_params[:client_second_phone], gender: booking_params[:client_gender], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
              if client.save
                new_booking_params[:client_id] = client.id
                client.save_attributes(params[:custom_attributes])
              else
                render :json => { :errors => ["El cliente no se pudo guardar: " + client.errors.full_messages.inspect] }, :status => 422
                return
              end
            end
          end
        end
      end
    end

    if ServiceProvider.where(:id => booking_params[:service_provider_id])
      new_booking_params[:location_id] = ServiceProvider.find(booking_params[:service_provider_id]).location.id
    end

    if @booking.price.nil?
      @booking.price = 0
    end

    respond_to do |format|

      if !new_booking_params[:service_id].blank? && new_booking_params[:service_id].to_i != @booking.service_id
        new_booking_params[:list_price] = Service.find(new_booking_params[:service_id]).price
      end

      session_booking_index = 0
      sessions_ratio = ""

      #If updated by admin, mark for user validation
      #Also, check if client was changed and update SessionBooking and all sessions


          if !@booking.payment_id.nil?
            @booking.payed_state = true
          end

          new_user = nil
          if !@booking.client.email.nil?
            if User.find_by_email(@booking.client.email).nil?
              new_user = User.find_by_email(@booking.client.email)
            end
          end

      # @booking.session_booking.bookings.each do |booking|

      #   booking.client_id = @booking.client_id
      #   if !new_user.nil?
      #     booking.user_id = new_user.id
      #   else
      #     booking.user_id = nil
      #   end
      #   booking.save
      # end

      #We need to check wether the booking was a treatment session or not

      # => If it was, we need to check if the service remains the same or not
      # =>    If it changes, we need to check if new service is a treatment or not
      # =>        If it's a treatment, we need to create it or book the according session (if there is a session_booking_id set), then generate and unbooked session for the old treatment
      # =>        If not, we just need to update the booking, then generate and unbooked session for the old treatment
      # =>        End
      # =>    If not, we just need to update the booking
      # =>    End
      # => If not, we need to check if the service remains the same or not
      # =>    If it changes, we need to check if the new service is a treatment or not
      # =>        If it is, we need to create it or book the according session (if there is a session_booking_id set)
      # =>        If not, we just need to update the booking
      # =>    If not, we just need to update the booking
      # => End
      old_service_id = @booking.service
      old_session_booking_id = @booking.session_booking_id
      was_session = @booking.is_session
      session_booking = nil

      if !booking_params[:status_id].blank?
        @booking.status_id = booking_params[:status_id]
      end
      if @booking.update(new_booking_params)

        #Check if new service has sessions before doing all the treatment checkings
        if !@booking.service.has_sessions
          @booking.is_session = false
          @booking.is_session_booked = false
          @booking.session_booking_id = nil
          @booking.user_session_confirmed = false
          @booking.save
        end

        if was_session
          if @booking.service_id != old_service_id
            if @booking.is_session || @booking.service.has_sessions
              #Update
              #Create treatment or book new session
              #Add a fresh unbooked session for old treatment (session_booking)
              #Do this by changing their session_booking_ids
              if !booking_params[:session_booking_id].blank? && booking_params[:session_booking_id].to_i != 0

                session_booking = SessionBooking.find(booking_params[:session_booking_id])

                if !session_booking.nil?
                  #There is session_booking, book a session, unbook for old_treatment
                  @booking.session_booking_id = session_booking.id

                  discharged_booking = session_booking.bookings.where(is_session_booked: false).last
                  discharged_booking.delete

                  session_booking.sessions_taken += 1
                  session_booking.save

                  old_session_booking = SessionBooking.find(old_session_booking_id)

                  restored_booking = old_session_booking.bookings.last.dup
                  restored_booking.id = nil
                  restored_booking.is_session_booked = false
                  restored_booking.save

                  old_session_booking.sessions_taken -= 1
                  old_session_booking.save

                else
                  #There is no session_booking, create the rest of the sessions, unbook for old treatment

                  session_booking = SessionBooking.create(sessions_taken: 1, service_id: @booking.service_id, user_id: @booking.user_id, client_id: @booking.client_id, sessions_amount: @booking.service.sessions_amount, max_discount: 0, treatment_promo_id: nil)

                  @booking.session_booking_id = session_booking.id

                  for i in 1..session_booking.sessions_amount-1
                    new_booking = @booking.dup
                    new_booking.is_session = true
                    new_booking.is_session_booked = false
                    new_booking.user_session_confirmed = false
                    new_booking.session_booking_id = session_booking.id
                    new_booking.save
                  end

                  old_session_booking = SessionBooking.find(old_session_booking_id)

                  restored_booking = old_session_booking.bookings.last.dup
                  restored_booking.id = nil
                  restored_booking.is_session_booked = false
                  restored_booking.save

                  old_session_booking.sessions_taken -= 1
                  old_session_booking.save

                end

              else
                #There is no session_booking, create the rest of the sessions, unbook for old treatment

                session_booking = SessionBooking.create(sessions_taken: 1, service_id: @booking.service_id, user_id: @booking.user_id, client_id: @booking.client_id, sessions_amount: @booking.service.sessions_amount, max_discount: 0, treatment_promo_id: nil)

                  @booking.session_booking_id = session_booking.id

                  for i in 1..session_booking.sessions_amount-1
                    new_booking = @booking.dup
                    new_booking.is_session = true
                    new_booking.is_session_booked = false
                    new_booking.user_session_confirmed = false
                    new_booking.session_booking_id = session_booking.id
                    new_booking.save
                  end

                  old_session_booking = SessionBooking.find(old_session_booking_id)

                  restored_booking = old_session_booking.bookings.last.dup
                  restored_booking.id = nil
                  restored_booking.is_session_booked = false
                  restored_booking.save

                  old_session_booking.sessions_taken -= 1
                  old_session_booking.save

              end

              @booking.is_session = true
              @booking.is_session_booked = true
              if !@booking.payment_id.nil?
                @booking.payed_state = true
              end

              #Check for payment for confirmation status
              if @booking.payed
                @booking.user_session_confirmed = false
              else
                @booking.user_session_confirmed = true
              end

              @booking.save

              session_index = 1
              Booking.where(:session_booking_id => @booking.session_booking.id, :is_session_booked => true).order('start asc').each do |b|
                if b.id == @booking.id
                  break
                else
                  session_index = session_index + 1
                end
              end

              sessions_ratio = "Sesión " + session_index.to_s + " de " + @booking.session_booking.sessions_amount.to_s

              if @booking.user_session_confirmed && @booking.send_mail
                @booking.session_booking.send_sessions_booking_mail
              else
                if @booking.payed && @booking.send_mail
                  @booking.send_admin_payed_session_mail
                else
                  @booking.send_validate_mail
                end
              end

            else
              #Update
              #Add a fresh unbooked session for old treatment (session_booking)

              @booking.session_booking_id = nil
              @booking.is_session = false
              @booking.is_session_booked = false
              @booking.save

              old_session_booking = SessionBooking.find(old_session_booking_id)

              restored_booking = old_session_booking.bookings.last.dup
              restored_booking.id = nil
              restored_booking.is_session_booked = false
              restored_booking.save

              old_session_booking.sessions_taken -= 1
              old_session_booking.save

            end
          else
            #Just update, so do nothing
          end
        else
          if @booking.service_id != old_service_id
            if @booking.is_session || @booking.service.has_sessions
              if !booking_params[:session_booking_id].blank? && booking_params[:session_booking_id].to_i != 0
                #There is session_booking, book a session
                session_booking = SessionBooking.find(booking_params[:session_booking_id])

                if !session_booking.nil?
                  @booking.session_booking_id = session_booking.id


                  discharged_booking = session_booking.bookings.where(is_session_booked: false).last
                  discharged_booking.delete

                  session_booking.sessions_taken += 1
                  session_booking.save
                else
                  session_booking = SessionBooking.create(sessions_taken: 1, service_id: @booking.service_id, user_id: @booking.user_id, client_id: @booking.client_id, sessions_amount: @booking.service.sessions_amount, max_discount: 0, treatment_promo_id: nil)

                  @booking.session_booking_id = session_booking.id

                  for i in 1..session_booking.sessions_amount-1
                    new_booking = @booking.dup
                    new_booking.is_session = true
                    new_booking.is_session_booked = false
                    new_booking.user_session_confirmed = false
                    new_booking.session_booking_id = session_booking.id
                    new_booking.save
                  end

                end
              else
                #There is no session_booking, create the rest of the session
                session_booking = SessionBooking.create(sessions_taken: 1, service_id: @booking.service_id, user_id: @booking.user_id, client_id: @booking.client_id, sessions_amount: @booking.service.sessions_amount, max_discount: 0, treatment_promo_id: nil)

                @booking.session_booking_id = session_booking.id

                for i in 1..session_booking.sessions_amount-1
                  new_booking = @booking.dup
                  new_booking.is_session = true
                  new_booking.is_session_booked = false
                  new_booking.user_session_confirmed = false
                  new_booking.session_booking_id = session_booking.id
                  new_booking.save
                end

              end

              @booking.is_session = true
              @booking.is_session_booked = true

              if !@booking.payment_id.nil?
                @booking.payed_state = true
              end

              #Check if payed for confirmation status
              if @booking.payed
                @booking.user_session_confirmed = false
              else
                @booking.user_session_confirmed = true
              end

              @booking.save

              session_index = 1
              Booking.where(:session_booking_id => @booking.session_booking.id, :is_session_booked => true).order('start asc').each do |b|
                if b.id == @booking.id
                  break
                else
                  session_index = session_index + 1
                end
              end

              sessions_ratio = "Sesión " + session_index.to_s + " de " + @booking.session_booking.sessions_amount.to_s

              if @booking.user_session_confirmed && @booking.send_mail
                @booking.session_booking.send_sessions_booking_mail
              else
                if @booking.payed && @booking.send_mail
                  @booking.send_admin_payed_session_mail
                else
                  @booking.send_validate_mail
                end
              end

            else
              #Just update, so do nothing
            end
          else
            #Just update, so do nothing
          end
        end

        ############
        ## LEGACY ##
        ############
        # if @booking.is_session

        #   new_user = nil
        #   if !@booking.client.email.nil?
        #     if User.find_by_email(@booking.client.email).nil?
        #       new_user = User.find_by_email(@booking.client.email)
        #     end
        #   end

        #   @booking.session_booking.bookings.each do |booking|
        #     booking.client_id = @booking.client_id
        #     if !new_user.nil?
        #       booking.user_id = new_user.id
        #     else
        #       booking.user_id = nil
        #     end
        #     booking.save
        #   end

        #   @booking.session_booking.client_id = @booking.client_id
        #   if !new_user.nil?
        #     @booking.session_booking.user_id = new_user.id
        #   else
        #     @booking.session_booking.user_id = nil
        #   end
        #   @booking.session_booking.save


        #   if @booking.user_session_confirmed
        #     @booking.session_booking.send_sessions_booking_mail
        #   else
        #     if @booking.payed
        #       @booking.send_admin_payed_session_mail
        #     else
        #       @booking.send_validate_mail
        #     end
        #   end

        #   session_index = 1
        #   Booking.where(:session_booking_id => @booking.session_booking.id, :is_session_booked => true).order('start asc').each do |b|
        #     if b.id == @booking.id
        #       break
        #     else
        #       session_index = session_index + 1
        #     end
        #   end

        #   sessions_ratio = "Sesión " + session_index.to_s + " de " + @booking.session_booking.sessions_amount.to_s

        # else

        #   if @booking.service.has_sessions


        #     should_create_sessions = false
        #     session_booking = nil


        #     if booking_params[:session_booking_id]
        #       if booking_params[:session_booking_id] != "0" && booking_params[:session_booking_id] != 0
        #         session_booking = SessionBooking.find(booking_params[:session_booking_id])
        #         #session_booking.sessions_taken = session_booking.sessions_taken + 1
        #         #@booking = Booking.where(:session_booking_id => session_booking.id, :is_session_booked => false).first
        #         #@booking.start = booking_params[:start]
        #         #@booking.end = booking_params[:end]
        #         #@booking.service_provider_id = booking_params[:service_provider_id]
        #         @booking.session_booking_id = session_booking.id
        #         @booking.is_session = true
        #         @booking.is_session_booked = true
        #         if @booking.payed
        #           @booking.user_session_confirmed = false
        #         else
        #           @booking.user_session_confirmed = true
        #         end

        #         session_booking.sessions_taken = session_booking.sessions_taken+1
        #         session_booking.save

        #         @booking.save
        #       else
        #         should_create_sessions = true
        #         session_booking = SessionBooking.new
        #         #session_booking.sessions_taken = 1
        #         serv = Service.find(booking_params[:service_id])
        #         session_booking.service_id = booking_params[:service_id]
        #         session_booking.sessions_amount = serv.sessions_amount

        #       end
        #     end

        #     # If it's a sessions service and it's the first session, save client and user for SessionBooking
        #     # and associate it with the @booking
        #     sessions_ratio = ""
        #     if should_create_sessions

        #       session_booking.client_id = @booking.client_id
        #       if User.find_by_email(booking_params[:client_email])
        #         session_booking.user_id = User.find_by_email(booking_params[:client_email]).id
        #       end

        #       session_booking.sessions_taken = 1
        #       session_booking.save
        #       @booking.session_booking_id = session_booking.id
        #       @booking.is_session = true
        #       @booking.is_session_booked = true
        #       if @booking.payed
        #         @booking.user_session_confirmed = false
        #       else
        #         @booking.user_session_confirmed = true
        #       end
        #       @booking.save
        #     end

        #     if should_create_sessions

        #       sessions_missing = session_booking.sessions_amount - 1
        #       sessions_ratio = "Sesión 1 de " + @booking.service.sessions_amount.to_s

        #       for i in 0..sessions_missing-1
        #         new_booking = @booking.dup
        #         new_booking.is_session = true
        #         new_booking.is_session_booked = false
        #         new_booking.user_session_confirmed = false
        #         new_booking.session_booking_id = session_booking.id
        #         new_booking.save
        #       end

        #     elsif !session_booking.nil?
        #       session_booking.save

        #       session_index = 1
        #       Booking.where(:session_booking_id => session_booking.id, :is_session_booked => true).order('start asc').each do |b|
        #         if b.id == @booking.id
        #           break
        #         else
        #           session_index = session_index + 1
        #         end
        #       end

        #       sessions_ratio = "Sesión " + session_index.to_s + " de " + session_booking.sessions_amount.to_s

        #     end

        #   end

        # end

        ################
        ## END LEGACY ##
        ################

        u = @booking
        if u.warnings then warnings = u.warnings.full_messages else warnings = [] end
        @booking_json = {
          :id => u.id,
          :start => u.start,
          :end => u.end,
          :service_id => u.service_id,
          :service_provider_id => u.service_provider_id,
          :status_id => u.status_id,
          :first_name => u.client.first_name,
          :last_name => u.client.last_name,
          :email => u.client.email,
          :phone => u.client.phone,
          :notes => u.notes,
          :company_comment => u.company_comment,
          :provider_lock => u.provider_lock,
          :service_name => u.service.name,
          :warnings => warnings ,
          :is_session => u.is_session,
          :is_session_booked => u.is_session_booked,
          :user_session_confirmed => u.user_session_confirmed,
          :sessions_ratio => sessions_ratio,
          :payed_state => u.payed_state,
          :bundled => u.bundled,
          :location_id => u.location_id
        }
        BookingHistory.create(booking_id: @booking.id, action: "Modificada por Calendario", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: current_user.id, staff_code_id: staff_code, notes: @booking.notes, company_comment: @booking.company_comment)
        format.html { redirect_to bookings_path, notice: 'Booking was successfully updated.' }
        format.json { render :json => @booking_json }
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
    @company_setting = current_user.company.company_setting
    if @company_setting.staff_code
      if booking_params[:staff_code] && !booking_params[:staff_code].empty? && StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code], active: true).count > 0
        staff_code = StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code], active: true).first.id
      else
        render :json => { :errors => ["El código de empleado ingresado no es correcto."] }, :status => 422
        return
      end
    end
    status = @booking.status.id
    is_booked = @booking.is_session_booked
    @bookings = Booking.where(id: @booking.id)
    if !@booking.is_session
      status = Status.find_by(:name => 'Cancelado').id
      if booking_params[:bundled_delete] == "true"
        @bookings = Booking.where(bundle_id: @booking.bundle_id, client_id: @booking.client_id, booking_group: @booking.booking_group)
      end
    else
      status = Status.find_by(:name => 'Cancelado').id
      is_booked = false
    end
    # @booking.destroy
    respond_to do |format|
      if @bookings.update_all(status_id: status, is_session_booked: false) >= @bookings.count
        @bookings.each do |booking|
          BookingHistory.create(booking_id: booking.id, action: "Cancelada por Calendario", start: booking.start, status_id: booking.status_id, service_id: booking.service_id, service_provider_id: booking.service_provider_id, user_id: current_user.id, notes: booking.notes, company_comment: booking.company_comment)
          if booking.is_session
            booking.session_booking.sessions_taken -= 1
            booking.session_booking.save
            if booking.send_mail
              booking.send_session_cancel_mail
            end
          end
        end
        format.html { redirect_to bookings_url }
        format.json { render :json => @bookings.pluck(:id) }
      else
        format.html { redirect_to bookings_url }
        format.json { render :json => { :errors => "No se puedieron cancelar todas las reservas." }, :status => 422 }
      end
    end
  end

  def delete_session_booking

    @booking.user_session_confirmed = false
    @booking.is_session_booked = false
    @booking.status_id = Status.find_by_name("Cancelado").id
    #Send cancel mail
    @json_response = []

    if @booking.save

      @booking.session_booking.sessions_taken -= 1
      @booking.session_booking.save

      @booking.send_session_update_mail
      #respond_to do |format|
      #  format.html { redirect_to bookings_url }
      #  format.json { render :json => @booking }
      #end
      @json_response << "ok"
      @json_response << @booking
      render :json => @json_response
    else
      #@errors = []
      #@errors << "Hubo un problema al eliminar la sesión."
      #respond_to do |format|
      #  format.html { redirect_to bookings_url }
      #  format.json { render :json => @errors }
      #end
      @json_response << "error"
      @json_response << @booking.errors
      render :json => @json_response
    end
  end

  def delete_treatment

    @session_booking = @booking.session_booking
    booking_ids = @session_booking.bookings.pluck(:id)
    respond_to do |format|
      if @session_booking.destroy
        TreatmentLog.create(client_id: @session_booking.client_id, user_id: current_user.id, service_id: @session_booking.service_id, detail: "Eliminado por calendario.")
        format.html { redirect_to bookings_url }
        format.json { render :json => booking_ids }
      else
        format.html { redirect_to bookings_url }
        format.json { render :json => { :errors => "No se pudo borrar el tratamiento." }, :status => 422 }
      end
    end

  end

  def user_delete_treatment

    @session_booking = SessionBooking.find(params[:session_booking_id])
    @json_response = []

    if current_user.nil? || current_user.id != @session_booking.user_id
      @json_response << "error"
      @json_response << "No puedes borrar un tratamiento no asociado a tu usuario."
      render :json => @json_response
      return
    end

    booking_ids = @session_booking.bookings.pluck(:id)


    if @session_booking.destroy
      @json_response << "ok"
      @json_response << @booking
      render :json => @json_response
    else
      @json_response << "error"
      @json_response << @session_booking.errors
      render :json => @json_response
    end

  end

  #GET
  def validate_session_form

    @error = []
    unless params[:id]
      crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
      id = crypt.decrypt_and_verify(params[:confirmation_code])
      @booking = Booking.find(id)

    else
      @booking = Booking.find(params[:id])
      @booking.user_session_confirmed = true
      if @booking.save
        current_user ? user = current_user.id : user = 0
        BookingHistory.create(booking_id: @booking.id, action: "Cancelada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)

        #Send mail to providerZ
        @booking.send_validate_mail

      else
        flash[:alert] = "Hubo un error cancelando tu reserva. Inténtalo nuevamente."
        @errors = @booking.errors
      end
    end
    @company = @booking.location.company
    render layout: "workflow"

  end

  #POST
  def validate_session_booking

    #Send mail as if it was a new booking
    @booking.user_session_confirmed = true
    @json_response = []
    if @booking.save
      #Send mail to providerZ
      @booking.send_validate_mail
      @json_response << "ok"
      @json_response << @booking
      render :json => @json_response
    else
      @json_response << "error"
      @json_response << @booking.errors
      render :json => @json_response
    end
  end

  def session_booking_detail
    respond_to do |format|
      format.html { render :partial => 'session_booking_detail' }
      format.json { render :json => @booking }
    end
  end

  def book_session_form
    #if params[:edit]
    #  @startDate = @booking.start
    #end
    respond_to do |format|
      format.html { render :partial => 'book_session_form' }
      format.json { render :json => @booking }
    end
  end

  def update_book_session
    #Send update mail
    @booking = Booking.find(params[:id])
    @booking.start = params[:start]
    @booking.end = params[:end]
    @booking.service_provider_id = params[:service_provider_id]
    @booking.is_session = true
    @booking.is_session_booked = true
    @booking.user_session_confirmed = true

    @response = []

    @errors = []

    @response << @errors
    @response << @booking

    block_it = false
    service_provider = ServiceProvider.find(params[:service_provider_id])
    service = @booking.service

    service_provider.provider_breaks.where("provider_breaks.start < ?", params[:end].to_datetime).where("provider_breaks.end > ?", params[:start].to_datetime).each do |provider_break|
      if (provider_break.start.to_datetime - params[:end].to_datetime) * (params[:start].to_datetime - provider_break.end.to_datetime) > 0
        @errors << "Lo sentimos, la hora " + I18n.l(params[:start].to_datetime) + " con " + service_provider.public_name + " está bloqueada."
        block_it = true
        next
      end
    end
    service_provider.bookings.where("bookings.start < ?", params[:end].to_datetime).where("bookings.end > ?", params[:start].to_datetime).each do |provider_booking|
      unless provider_booking.status_id == Status.find_by_name("Cancelado").id
        if (provider_booking.start.to_datetime - params[:end].to_datetime) * (params[:start].to_datetime - provider_booking.end.to_datetime) > 0
          if !service.group_service || service.id.to_i != provider_booking.service_id
            if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
              @errors << "Lo sentimos, la hora " + I18n.l(params[:start].to_datetime) + " con " + service_provider.public_name + " ya fue reservada por otro cliente."
              block_it = true
              next
            end
          elsif service.group_service && service.id.to_i == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => params[:start].to_datetime).where.not(status_id: Status.find_by_name('Cancelado')).count >= service.capacity
            if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
              @errors << "Lo sentimos, la capacidad del servicio grupal " + service.name + " llegó a su límite."
              block_it = true
              next
            end
          end
        end
      end
    end


    if !block_it and @booking.save
      @booking.send_session_update_mail
      respond_to do |format|
        format.json { render :json => @response }
      end
    else
      respond_to do |format|
        format.json { render :json => @response }
      end
    end
  end

  def sessions_calendar
    @booking = Booking.find(params[:id])
    @selectedProvider = params[:service_provider_id]
    respond_to do |format|
      format.html { render :partial => 'sessions_calendar' }
      format.json { render :json => @booking }
    end
  end

  def booking_history
    staff_code = '-'
    user = '-'
    bookings = []
    BookingHistory.where(booking_id: params[:booking_id]).order(created_at: :desc).each do |booking_history|
      if current_user.role_id == Role.find_by_name('Administrador General').id || current_user.role_id == Role.find_by_name('Administrador Local').id || current_user.role_id == Role.find_by_name('Recepcionista').id
        if booking_history.staff_code
          staff_code = booking_history.staff_code.staff
        end
        user = 'Usuario no registrado'
        if booking_history.user_id && booking_history.user_id > 0 && booking_history.user
          user = booking_history.user.email
        end
      end
      timezone = CustomTimezone.from_booking_history(booking_history)
      bookings.push( { action: booking_history.action, created: booking_history.created_at, start: booking_history.start, service: booking_history.service.name, provider: booking_history.service_provider.public_name, status: booking_history.status.name, user: user, staff_code: staff_code, notes: booking_history.notes, company_comment: booking_history.company_comment, time_offset: timezone.offseti } )
    end
    render :json => bookings
  end

  def get_booking
    booking = Booking.find(params[:id])
    render :json => booking
  end

  def get_booking_for_payment
    booking = Booking.find(params[:id])
    discount = 0
    #if booking.service.price != 0
    #  discount = 100*((booking.service.price - booking.price)/booking.service.price).round(1)
    #end

    #Return list_price and discount. Their combination should equal price. Return service_price also, just for reference.

    render :json => {id: booking.id, service_name: booking.service.name, service_price: booking.service.price, discount: booking.discount, price: booking.price, list_price: booking.list_price}
  end

  def get_session_booking_for_payment

    bookings_arr = Booking.find(params[:booking_ids])
    discount = 0
    bookings = []

    bookings_arr.each do |booking|
      bookings << {id: booking.id, service_name: booking.service.name, service_price: booking.service.price, discount: booking.discount, price: booking.price, list_price: booking.list_price}
    end
    #if booking.service.price != 0
    #  discount = 100*((booking.service.price - booking.price)/booking.service.price).round(1)
    #end

    #Return list_price and discount. Their combination should equal price. Return service_price also, just for reference.

    render :json => bookings
  end

  def get_booking_info
    booking = Booking.find(params[:id])
    render :json => {service_provider_active: booking.service_provider.active, service_active: booking.service.active, service_provider_name: booking.service_provider.public_name, service_name: booking.service.name}
  end

  def provider_booking
    statusIcon = [" blocked", " reserved", " confirmed", " completed", " payed", " cancelled", " noshow", " break"]
    if params[:provider] != "0"
      @providers = ServiceProvider.where(:id => params[:provider])
    else
      @providers = ServiceProvider.where(:location_id => params[:location], active: true)
    end

    start_date = DateTime.parse(params[:start])
    end_date = DateTime.parse(params[:end])

    events = Array.new

    @cancelled_id = Status.find_by_name('Cancelado').id

    @bookings = Booking.where('bookings.service_provider_id IN (?)', @providers.pluck(:id)).where('(bookings.start,bookings.end) overlaps (date ?,date ?)', end_date, start_date).where('bookings.is_session = false or (bookings.is_session = true and bookings.is_session_booked = true)').includes(:client).includes(:service).includes(:session_booking)

    @bookings.each do |booking|
      if booking.status_id != @cancelled_id
        event = Hash.new
        booking.provider_lock ? providerLock = '-lock' : providerLock = '-unlock'
        booking.web_origin ? originClass = 'origin-web' : originClass = 'origin-manual'

        payedClass = ''
        if booking.payed_state
          payedClass = ' payed'
        end
        bundleClass = ''
        if booking.bundled
          bundleClass = ' bundle'
        end
        originClass += providerLock + statusIcon[booking.status_id] + payedClass + bundleClass

        title = ''
        qtip = ''
        phone = ''
        email = ''
        comment = ''
        prepayed = ''
        is_session = false
        sessions_ratio = ''

        if booking.client.first_name
          title += booking.client.first_name
          qtip += booking.client.first_name
        end
        if booking.client.last_name
          title += ' ' + booking.client.last_name
          qtip += ' ' + booking.client.last_name
        end
        if booking.service.name
          title += ' - ' + booking.service.name
        end

        # Se verifica que existan los datos y en caso contrario, se deja como string vacío para evitar nulos en los Qtips

        phone = booking.client.phone if booking.client.phone

        email = booking.client.email if booking.client.email

        comment = booking.company_comment if booking.company_comment

        if booking.payed_state
          prepayed = 'Sí'
        else
          prepayed = 'No'
        end

        if booking.is_session && booking.session_booking
          is_session = true
          session_index = 1
          Booking.where(:session_booking_id => booking.session_booking_id, :is_session_booked => true).order('start asc').each do |b|
            if b.id == booking.id
              break
            else
              session_index = session_index + 1
            end
          end
          sessions_ratio = "Sesión " + session_index.to_s + " de " + booking.session_booking.sessions_amount.to_s
        else
          sessions_ratio = "0/0"
          is_session = false
        end


        if booking.is_session && booking.is_session_booked && !booking.user_session_confirmed
          originClass += ' session'
        end

        event = {
          id: booking.id,
          title: title,
          allDay: false,
          start: booking.start,
          end: booking.end,
          resourceId: booking.service_provider_id,
          className: originClass,
          title_qtip: qtip,
          time_qtip: booking.start.strftime("%H:%M") + ' - ' + booking.end.strftime("%H:%M"),
          service_qtip: booking.service.name,
          phone_qtip: phone,
          email_qtip: email,
          comment_qtip: comment,
          prepayed_qtip: prepayed,
          is_session_qtip: is_session,
          sessions_ratio_qtip: sessions_ratio,
          identification_number_qtip: booking.client.identification_number ? booking.client.identification_number : ""
        }

        events.push(event)
      end
    end

    @breaks = ProviderBreak.where('(provider_breaks.start,provider_breaks.end) overlaps (date ?,date ?)', start_date, end_date).where(:service_provider_id => @providers).order(:start)

    @breaks.each do |provider_break|
      if provider_break.name && provider_break.name != ""
        label = provider_break.name
      else
        label = 'Hora Bloqueada'
      end

      event = {
        id: 'b'+provider_break.id.to_s,
        title: label,
        allDay: false,
        start: provider_break.start,
        end: provider_break.end,
        resourceId: provider_break.service_provider_id,
        className: 'break'
      }
      events.push(event)
    end

    if start_date.wday == 0
      day_number = 7
    else
      day_number = start_date.wday
    end

    times = Array.new

    @providers.each do |provider|
      event = Hash.new
      event = {
        id: 'pp'+provider.id.to_s,
        title: 'Bloqueo por Horario',
        allDay: false,
        editable: false,
        start: start_date,
        end: end_date,
        resourceId: provider.id,
        className: 'blocked'
      }
      provider.provider_times.order(:day_id, :open).each do |provider_time|
        offset = (provider_time.day_id - day_number)
        time_start = start_date.change(hour: provider_time.open.hour, min: provider_time.open.min) + (provider_time.day_id - day_number).days
        time_end = start_date.change(hour: provider_time.close.hour, min: provider_time.close.min) + (provider_time.day_id - day_number).days
        event[:end] = time_start
        if event[:start] < event[:end] && event[:start] < end_date && event[:end] > start_date
          events.push(event)
        end
        event = Hash.new
        event = {
          id: 'p'+provider_time.id.to_s,
          title: 'Bloqueo por Horario',
          allDay: false,
          editable: false,
          start: time_end,
          end: time_start,
          resourceId: provider.id,
          className: 'blocked'
        }
      end
      event[:end] = end_date
      events.push(event)
    end

    respond_to do |format|
      msg = { events: events }
      format.json { render :json => events }
    end
  end

  def book_service

    if params[:location].blank?
      flash[:alert] = "Lo sentimos, el local ingresado no existe."
      redirect_to root_path
      return
    elsif params[:bookings].blank?
      flash[:alert] = "Error ingresando los datos."
      redirect_to workflow_path(:local => params[:location])
      return
    end

    @bookings = []
    @errors = []
    @blocked_bookings = []

    @location_id = params[:location]
    @selectedLocation = Location.find(@location_id)
    @company = Location.find(params[:location]).company
    cancelled_id = Status.find_by(name: 'Cancelado').id

    # => Domain parser
    host = request.host_with_port
    @url = @selectedLocation.get_web_address + '.' + host[host.index(request.domain)..host.length]

    booking_data = JSON.parse(params[:bookings], symbolize_names: true)

    if !user_signed_in?
      if params[:mailing_option].blank?
        params[:mailing_option] = false
      end
      if MailingList.where(email: params[:email]).count > 0
        MailingList.where(email: params[:email]).first.update(first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], mailing_option: params[:mailing_option])
      else
        MailingList.create(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], mailing_option: params[:mailing_option])
      end
    end

    if @company.company_setting.client_exclusive
      if(params[:client_id])
        client = Client.find(params[:client_id])
      elsif Client.where(identification_number: params[:identification_number], company_id: @company).count > 0
        client = Client.where(identification_number: params[:identification_number], company_id: @company).first
        client.email = params[:email]
        client.phone = params[:phone]
        if client.save
          client.save_attributes(params)
        else
          @errors << client.errors.full_messages
          render layout: "workflow"
          return
        end
      else
        @errors << "No estás ingresado como cliente"
        render layout: "workflow"
        return
      end
    elsif @company.company_setting.use_identification_number
      if !params[:identification_number].blank?
        if Client.where(email: params[:email], company_id: @company).count > 0
          client = Client.where(email: params[:email], company_id: @company).first
          client.first_name = params[:firstName]
          client.last_name = params[:lastName]
          client.phone = params[:phone]
          client.identification_number = params[:identification_number]
          if client.save
            client.save_attributes(params)
          else
            @errors << client.errors.full_messages
            render layout: "workflow"
            return
          end
        else
          client = Client.new(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], identification_number: params[:identification_number], company_id: @company.id)
          if client.save
            client.save_attributes(params)
          else
            @errors << client.errors.full_messages
            render layout: "workflow"
            return
          end
        end
      else
        @errors << "No se ingresó " + (I18n.t('ci')).capitalize + " de cliente"
        render layout: "workflow"
        return
      end
    else
      if Client.where(email: params[:email], company_id: @company).count > 0
        client = Client.where(email: params[:email], company_id: @company).first
        client.first_name = params[:firstName]
        client.last_name = params[:lastName]
        client.phone = params[:phone]
        if client.save
          client.save_attributes(params)
        else
          @errors << client.errors.full_messages
          render layout: "workflow"
          return
        end
      else
        client = Client.new(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], company_id: @company.id)
        if client.save
          client.save_attributes(params)
        else
          @errors << client.errors.full_messages
          render layout: "workflow"
          return
        end
      end
    end

    if params[:comment].blank?
      params[:comment] = ''
    end

    if params[:address] && !params[:address].empty?
      params[:comment] += ' - Dirección del cliente (donde se debe realizar el servicio): ' + params[:address]
    end

    #booking_data = JSON.parse(params[:bookings], symbolize_names: true)
    #is_session_booking = booking_data[0].has_sessions

    deal = nil
    if @company.company_setting.deal_activate
      if Deal.where(code: params[:deal_code], company_id: @company).count > 0
        deal = Deal.where(code: params[:deal_code], company_id: @company).first
        if deal.quantity> 0 && deal.bookings.where.not(status_id: cancelled_id).count >= deal.quantity
          @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida."
        elsif deal.constraint_option > 0 && deal.constraint_quantity > 0
          booking_data.each do |buffer_params|
            if deal.constraint_option == 1
              if deal.bookings.where.not(status_id: cancelled_id).where(start: buffer_params[:start].to_datetime).count >= deal.constraint_quantity
                @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida simultáneamente."
                break
              end
            elsif deal.constraint_option == 2
              if deal.bookings.where.not(status_id: cancelled_id).where(start: buffer_params[:start].to_datetime.beginning_of_day..buffer_params[:start].to_datetime.end_of_day).count >= deal.constraint_quantity
                @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida por día."
                break
              end
            elsif deal.constraint_option == 3
              if deal.bookings.where.not(status_id: cancelled_id).where(start: buffer_params[:start].to_datetime.beginning_of_week..buffer_params[:start].to_datetime.end_of_week).count >= deal.constraint_quantity
                @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida por semana."
                break
              end
            elsif deal.constraint_option == 4
              if deal.bookings.where.not(status_id: cancelled_id).where(start: buffer_params[:start].to_datetime.beginning_of_month..buffer_params[:start].to_datetime.end_of_month).count >= deal.constraint_quantity
                @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida por mes."
                break
              end
            end
          end
        end
        if @errors.length > 0
          render layout: "workflow"
          return
        end
      else
        if !@company.company_setting.deal_exclusive
          deal = Deal.create(company_id: @company.id, code: params[:deal_code], quantity: @company.company_setting.deal_quantity, constraint_option: @company.company_setting.deal_constraint_quantity, constraint_quantity: @company.company_setting.deal_constraint_quantity)
        else
          @errors << "Convenio es inválido o inexistente."
          render layout: "workflow"
          return
        end
      end
    end



    booking_group = nil
    if booking_data.length > 1
      provider = booking_data[0][:provider]
      location = ServiceProvider.find(provider).location

      group = Booking.where(location: location).where.not(booking_group: nil).order(:booking_group).last
      if group.nil?
        booking_group = 0
      else
        booking_group = group.booking_group + 1
      end
    end

    group_payment = false
    if(params[:payment] == "1")
      group_payment = true
    end
    final_price = 0

    @session_booking = nil
    @has_session_booking = false
    first_booking = nil
    sessions_service = nil

    if booking_data.size > 0
      if(params[:has_sessions] == "1" || params[:has_sessions] == 1)
        @has_session_booking = true
        @session_booking = SessionBooking.new
        session_service = Service.find(booking_data.first[:service])
        @session_booking.service_id = session_service.id
        @session_booking.client_id = client.id
        @session_booking.sessions_amount = session_service.sessions_amount
        @session_booking.max_discount = params[:max_discount].to_f
        if user_signed_in?
          @session_booking.user_id = current_user.id
        end
        #@session_booking.sessions_taken = booking_data.size
        @session_booking.save
      end
    end

    #Get service_promos and lower their stock
    service_promos_ids = []

    booking_data.each do |buffer_params|
      block_it = false
      service_provider = ServiceProvider.find(buffer_params[:provider])
      service = Service.find(buffer_params[:service])
      service_provider.provider_breaks.where("provider_breaks.start < ?", buffer_params[:end].to_datetime).where("provider_breaks.end > ?", buffer_params[:start].to_datetime).each do |provider_break|
        if (provider_break.start.to_datetime - buffer_params[:end].to_datetime) * (buffer_params[:start].to_datetime - provider_break.end.to_datetime) > 0
          if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
            @errors << "Lo sentimos, la hora " + I18n.l(buffer_params[:start].to_datetime) + " con " + service_provider.public_name + " está bloqueada."
            block_it = true
            next
          end
        end
      end
      service_provider.bookings.where("bookings.start < ?", buffer_params[:end].to_datetime).where("bookings.end > ?", buffer_params[:start].to_datetime).where('bookings.is_session = false or (bookings.is_session = true and bookings.is_session_booked = true)').each do |provider_booking|
        unless provider_booking.status_id == cancelled_id
          if (provider_booking.start.to_datetime - buffer_params[:end].to_datetime) * (buffer_params[:start].to_datetime - provider_booking.end.to_datetime) > 0
            if !service.group_service || buffer_params[:service].to_i != provider_booking.service_id
              if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
                @errors << "Lo sentimos, la hora " + I18n.l(buffer_params[:start].to_datetime) + " con " + service_provider.public_name + " ya fue reservada por otro cliente."
                block_it = true
                next
              end
            elsif service.group_service && buffer_params[:service].to_i == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => buffer_params[:start].to_datetime).where.not(status_id: Status.find_by_name('Cancelado')).count > service.capacity
              if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
                @errors << "Lo sentimos, la capacidad del servicio grupal " + service.name + " llegó a su límite."
                block_it = true
                next
              end
            end
          end
        end
      end

      if user_signed_in?
        @booking = Booking.new(
          start: buffer_params[:start],
          end: buffer_params[:end],
          notes: params[:comment],
          service_provider_id: service_provider.id,
          service_id: service.id,
          location_id: @selectedLocation.id,
          status_id: Status.find_by(name: 'Reservado').id,
          client_id: client.id,
          user_id: current_user.id,
          web_origin: params[:origin],
          provider_lock: buffer_params[:provider_lock],
          bundled: buffer_params[:bundled],
          bundle_id: buffer_params[:bundle_id]
        )
      else
        if User.find_by_email(params[:email])
          @user = User.find_by_email(params[:email])
          @booking = Booking.new(
            start: buffer_params[:start],
            end: buffer_params[:end],
            notes: params[:comment],
            service_provider_id: service_provider.id,
            service_id: service.id,
            location_id: @selectedLocation.id,
            status_id: Status.find_by(name: 'Reservado').id,
            client_id: client.id,
            user_id: @user.id,
            web_origin: params[:origin],
            provider_lock: buffer_params[:provider_lock],
            bundled: buffer_params[:bundled],
            bundle_id: buffer_params[:bundle_id]
          )
        else
          @booking = Booking.new(
            start: buffer_params[:start],
            end: buffer_params[:end],
            notes: params[:comment],
            service_provider_id: service_provider.id,
            service_id: service.id,
            location_id: @selectedLocation.id,
            status_id: Status.find_by(name: 'Reservado').id,
            client_id: client.id,
            web_origin: params[:origin],
            provider_lock: buffer_params[:provider_lock],
            bundled: buffer_params[:bundled],
            bundle_id: buffer_params[:bundle_id]
          )
        end
      end


      @booking.price = service.price
      @booking.list_price = service.price
      @booking.discount = service.discount
      @booking.max_changes = @company.company_setting.max_changes
      @booking.booking_group = booking_group

      if buffer_params[:bundled] == true || buffer_params[:bundled] == "true"
        @booking.price = ServiceBundle.find_by(service_id: service.id, bundle_id: buffer_params[:bundle_id]) ? ServiceBundle.find_by(service_id: service.id, bundle_id: buffer_params[:bundle_id]).price : service.price
      end

      if deal
        @booking.deal = deal
      end

      if block_it
        @blocked_bookings << @booking.service.name + " con " + @booking.service_provider.public_name + " el " + I18n.l(@booking.start.to_datetime)
      else
        if service.online_payable && buffer_params[:is_time_discount]
          service_promos_ids << buffer_params[:service_promo_id]
        end
        @bookings << @booking
      end

      if @has_session_booking
        @booking.is_session = true
        @booking.session_booking_id = @session_booking.id
        @booking.user_session_confirmed = true
        @booking.is_session_booked = true
      end

      #
      #   PAGO EN LÍNEA DE RESERVA
      #
      if(params[:payment] == "1")

        group_payment = true
        #Check if all payments are payable
        #Apply grouped discount

        #Check if all are payable
        #If not, pay those which may be paid
        #and book the others

        #if !service.online_payable
          #group_payment = false
          # Redirect to error
        #end

        #trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
        if service.online_payable

          if(params[:has_sessions] == "1" || params[:has_sessions] == 1)

            max_discount = params[:max_discount].to_f
            num_amount = (service.price - max_discount*service.price/100).round
            @booking.price = num_amount
            final_price = num_amount

            @booking.service_promo_id = nil
            @booking.last_minute_promo_id = nil

            if buffer_params[:is_treatment_discount]
              @session_booking.treatment_promo_id = buffer_params[:treatment_promo_id]
              @booking.treatment_promo_id = buffer_params[:treatment_promo_id]
            end
          else

            #num_amount = service.price
            #if service.has_discount
            #  num_amount = (service.price - service.price*service.discount/100).round;
            #end
              #final_price = final_price + num_amount
            #if @has_session_booking
              #final_price = num_amount
            #end

            num_amount = (service.price - buffer_params[:discount]*service.price/100).round

            if buffer_params[:is_time_discount]
              @booking.service_promo_id = buffer_params[:service_promo_id]
              service_promo = ServicePromo.find(buffer_params[:service_promo_id])
              #service_promo.max_bookings = service_promo.max_bookings - 1
            elsif params[:is_last_minute_promo]
              @booking.last_minute_promo_id = @booking.service.active_last_minute_promo_id
              last_minute_promo = @booking.service.active_last_minute_promo
            end

            @booking.price = num_amount
            final_price = final_price + num_amount

          end
        else
          @booking.price = service.price
        end
        #amount = sprintf('%.2f', num_amount)
        #payment_method = params[:mp]
        #req = PuntoPagos::Request.new()
        #resp = req.create(trx_id, amount, payment_method)
        # if resp.success?
        #   @booking.trx_id = trx_id
        #   @booking.token = resp.get_token
        #   if @booking.save
        #     current_user ? user = current_user.id : user = 0
        #     PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: amount, details: "Pago de servicio " + service.name + " a la empresa " +@company.name+" (" + @company.id.to_s + "). trx_id: "+trx_id+" - mp: "+@company.id.to_s+". Resultado: Se procesa")
        #     BookingHistory.create(booking_id: @booking.id, action: "Creada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user)
        #     redirect_to resp.payment_process_url and return
        #   else
        #     @errors = @booking.errors.full_messages
        #   end
        # else
        #   puts resp.get_error
        #   redirect_to punto_pagos_failure_path and return
        # end

      else #SÓLO RESERVA
        if @booking.save
          current_user ? user = current_user.id : user = 0
          BookingHistory.create(booking_id: @booking.id, action: "Creada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)
          logger.debug "Creada 1"
          if first_booking.nil?
            first_booking = @booking
          end
        else
          @errors << @booking.errors.full_messages
          @blocked_bookings << @booking.service.name + " con " + @booking.service_provider.public_name + " el " + I18n.l(@booking.start.to_datetime)
        end
      end

    end

    #If they can be payed, redirect to payment_process,
    #then check for error or send notifications mails.
    if group_payment

      trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')[0, 15]

      #######
      # START Recalculate final price so that there is no js injection
      #######

      if @has_session_booking

        sessions_max_discount = 0

        #Reset final price
        final_price = 0

        if @bookings.count > 0

          current_service = @bookings.first.service
          if !current_service.online_payable || !current_service.company.company_setting.online_payment_capable || !current_service.company.company_setting.allows_online_payment

            @errors << "El servicio " + current_service.name + " no puede ser pagado en línea."

            redirect_to book_error_path(bookings: @bookings.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: "payment", blocked_bookings: @blocked_bookings)
            return

          else

            treatment_discount = 0

            #
            # Assign prices in case there is no discount
            #
            @bookings.each do |booking|
              booking.price = current_service.price / current_service.sessions_amount
              booking.list_price = current_service.price / current_service.sessions_amount
              booking.discount = 0
            end

            # If discount is for online_payment, it's always equal.
            if current_service.has_discount && current_service.discount > 0
              @bookings.each do |booking|
                new_price = booking.price.to_f*((100.0 - current_service.discount.to_f)/100.0)
                booking.price = new_price
                #final_price = new_price
                if(booking.list_price > 0)
                  booking.discount = current_service.discount.to_f
                  treatment_discount = booking.discount
                else
                  booking.discount = 0
                end
              end
            end

            #Check for promotions
            if current_service.time_promo_active && current_service.has_treatment_promo && !current_service.active_treatment_promo.nil?
              if current_service.active_treatment_promo.max_bookings > 0 && current_service.active_treatment_promo.finish_date.end_of_day > DateTime.now

                @bookings.each do |booking|
                  if current_service.active_treatment_promo.discount > booking.discount
                    new_price = booking.price.to_f*((100.0 - booking.service.active_treatment_promo.discount.to_f/100.0))
                    booking.price = new_price
                    #final_price = new_price
                    if(booking.list_price > 0)
                      booking.discount = booking.service.active_treatment_promo.discount.to_f
                      treatment_discount = booking.discount
                    else
                      booking.discount = 0
                    end
                  end
                end

              end
            end

          end

          #Sum all booking prices (it could have service discount or treatment_promo)

          final_price = current_service.price * ((100.0 - treatment_discount.to_f)/100.0)

          logger.debug "***"
          logger.debug "Treatment price: " + final_price.to_s
          logger.debug "***"

        end

      else

        #Reset final_price

        final_price = 0

        # Just check for discount, correct the price and calculate final_price
        @bookings.each do |booking|

          if !booking.service.online_payable || !booking.service.company.company_setting.online_payment_capable || !booking.service.company.company_setting.allows_online_payment

            booking.price = booking.service.price
            logger.debug "list_price: " + booking.list_price.to_s
            logger.debug "price: " + booking.price.to_s

            if(booking.list_price > 0)
              booking.discount = (100*(booking.list_price - booking.price)/booking.list_price).round
            else
              booking.discount = 0
            end

          else

            #Assume there is no discount at first
            booking.price = booking.service.price
            booking.list_price = booking.service.price
            booking.discount = 0

            #First, check if it is last_minute_promo
            if params[:is_last_minute_promo]

              last_minute_promo = booking.service.active_last_minute_promo

              #LastMinutePromo.where(location_id: @selectedLocation.id, service_id: booking.service.id).first

              if last_minute_promo.nil?

                @errors << "La promoción de último minuto ya no existe."

                redirect_to book_error_path(bookings: @bookings.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: "payment", blocked_bookings: @blocked_bookings)
                return

              end

              if LastMinutePromoLocation.where(last_minute_promo_id: last_minute_promo.id, location_id: @selectedLocation.id).count == 0

                @errors << "La promoción de último minuto no existe para este local."

                redirect_to book_error_path(bookings: @bookings.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: "payment", blocked_bookings: @blocked_bookings)
                return

              end

              new_price = (booking.service.price - last_minute_promo.discount*booking.service.price/100).round
              booking.price = new_price
              #final_price = new_price
              if(booking.list_price > 0)
                booking.discount = (100*(booking.list_price - booking.price)/booking.list_price).round
              else
                booking.discount = 0
              end
            else
              #Check for online payment discount
              if booking.service.has_discount && booking.service.discount > 0

                new_book_price = (booking.service.price - booking.service.discount*booking.service.price/100).round
                booking.price = new_book_price
                booking.discount = booking.service.discount
                #final_price = final_price + new_book_price

              end

              #Now check for promos
              promo = Promo.where(:day_id => booking.start.to_datetime.cwday, :service_promo_id => booking.service.active_service_promo_id, :location_id => @selectedLocation.id).first

              new_book_discount = 0

              if !promo.nil?

                service_promo = ServicePromo.find(booking.service.active_service_promo_id)

                #Check if there is a limit for bookings, and if there are any left
                if service_promo.max_bookings > 0 || !service_promo.limit_booking

                  #Check if the promo is still active, and if the booking ends before the limit date

                  if booking.end.to_datetime < service_promo.book_limit_date && DateTime.now < service_promo.finish_date

                    if !(service_promo.morning_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.morning_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))

                      new_book_discount = promo.morning_discount

                    elsif !(service_promo.afternoon_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.afternoon_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))

                      new_book_discount = promo.afternoon_discount

                    elsif !(service_promo.night_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.night_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))

                      new_book_discount = promo.night_discount

                    end

                  end

                end

              end

              if booking.discount.nil? || booking.discount == 0 || booking.discount < new_book_discount

                new_book_price = (booking.service.price - new_book_discount*booking.service.price/100).round
                booking.price = new_book_price
                #final_price = final_price + new_book_price
                if(booking.list_price > 0)
                  booking.discount = (100*(booking.list_price - booking.price)/booking.list_price).round
                else
                  booking.discount = 0
                end
              end

            end

          end

        end

        #Prices were set, now sum them
        if @bookings.count > 0
          @bookings.each do |booking|
            final_price += booking.price
          end
        end

      end

      #####
      # END Recalculate final price so that there is no js injection
      #####


      amount = sprintf('%.2f', final_price)
      payment_method = params[:mp]
      req = PuntoPagos::Request.new()
      resp = req.create(trx_id, amount, payment_method)
      if resp.success?
        proceed_with_payment = true
        @bookings.each do |booking|

          if booking.service.online_payable
            booking.trx_id = trx_id
            booking.token = resp.get_token

            if booking.save
              current_user ? user = current_user.id : user = 0
              BookingHistory.create(booking_id: booking.id, action: "Creada por Cliente", start: booking.start, status_id: booking.status_id, service_id: booking.service_id, service_provider_id: booking.service_provider_id, user_id: user, notes: booking.notes, company_comment: booking.company_comment)
              logger.debug "Creada 2"
              if first_booking.nil?
                first_booking = booking
              end

            else
              @errors << booking.errors.full_messages
              proceed_with_payment = false
            end
          else
            if booking.save
              current_user ? user = current_user.id : user = 0
              BookingHistory.create(booking_id: booking.id, action: "Creada por Cliente", start: booking.start, status_id: booking.status_id, service_id: booking.service_id, service_provider_id: booking.service_provider_id, user_id: user, notes: booking.notes, company_comment: booking.company_comment)
              logger.debug "Creada 3"
              if first_booking.nil?
                first_booking = booking
              end
            else
              @errors << booking.errors.full_messages
              proceed_with_payment = false
            end
          end
        end
        #@blocked_bookings.each do |b_booking|
        #  b_booking.save
        #end

        @bookings.each do |b|
          if b.id.nil?
            @errors << "Hubo un error al guardar un servicio." + b.errors.inspect
            @blocked_bookings << b.service.name + " con " + b.service_provider.public_name + " el " + I18n.l(b.start.to_datetime)
            proceed_with_payment = false
          end
        end


        if @has_session_booking

          #@session_booking.sessions_taken = @bookings.size
          sessions_missing = @session_booking.sessions_amount - @bookings.size
          @session_booking.sessions_taken = @bookings.size
          @session_booking.save


          for i in 0..sessions_missing-1

            if !first_booking.nil?
              new_booking = first_booking.dup
              new_booking.is_session = true
              new_booking.session_booking_id = @session_booking.id
              new_booking.user_session_confirmed = false
              new_booking.is_session_booked = false

              if new_booking.save
                @bookings << new_booking
                current_user ? user = current_user.id : user = 0
                logger.debug "Creada 4"
              else
                @errors << new_booking.errors.full_messages
                @blocked_bookings << new_booking.service.name + " con " + new_booking.service_provider.public_name + " el " + I18n.l(new_booking.start.to_datetime)
                proceed_with_payment = false
              end
            else
              @errors << "No existen sesiones agendadas."
              @blocked_bookings << "No existen sesiones agendadas."
              proceed_with_payment = false
            end
          end

        end


        #Check for errors before starting payment
        if @errors.length > 0 and @blocked_bookings.count > 0
          books = []
          @bookings.each do |b|
            if !b.id.nil?
              books << b
            end
          end
          redirect_to book_error_path(bookings: books.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: "payment", blocked_bookings: @blocked_bookings)
          return
        end

        if proceed_with_payment

          if @has_session_booking
            if !@bookings.first.service.active_treatment_promo_id.nil?
              treatment_promo = TreatmentPromo.find(@bookings.first.service.active_treatment_promo_id)
              treatment_promo.max_bookings = treatment_promo.max_bookings - 1
              treatment_promo.save
            end
          else

            @bookings.each do |booking|
              if !booking.service_promo_id.nil?
                service_promo = ServicePromo.find(booking.service_promo_id)
                service_promo.max_bookings = service_promo.max_bookings - 1
                service_promo.save
              end
            end

          end

          PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: amount, details: "Pago de varios servicios a la empresa " +@company.name+" (" + @company.id.to_s + "). trx_id: "+trx_id+" - mp: "+@company.id.to_s+". Resultado: Se procesa")
          redirect_to resp.payment_process_url and return
        else
          puts resp.get_error
          redirect_to punto_pagos_failure_path and return
        end
      else
        @bookings.each do |booking|
            booking.delete
        end
        puts resp.get_error
        redirect_to punto_pagos_failure_path and return
      end
    end

    #Add bookings for all the sessions that where not booked
    if @has_session_booking

      #@session_booking.sessions_taken = @bookings.size
      sessions_missing = @session_booking.sessions_amount - @bookings.size
      @session_booking.sessions_taken = @bookings.size
      @session_booking.save


      for i in 0..sessions_missing-1

        if !first_booking.nil?
          new_booking = first_booking.dup
          new_booking.is_session = true
          new_booking.session_booking_id = @session_booking.id
          new_booking.user_session_confirmed = false
          new_booking.is_session_booked = false

          if new_booking.save
            @bookings << new_booking
            current_user ? user = current_user.id : user = 0
            logger.debug "Creada 5"
          else
            @errors << new_booking.errors.full_messages
            @blocked_bookings << new_booking.service.name + " con " + new_booking.service_provider.public_name + " el " + I18n.l(new_booking.start.to_datetime)
          end
        else
          @errors << "No existen sesiones agendadas."
          @blocked_bookings << "No existen sesiones agendadas."
        end
      end

    end

    str_payment = "book"
    if group_payment
      str_payment = "payment"
    end

    @bookings.each do |b|
      if b.id.nil?
        @errors << "Hubo un error al guardar un servicio. " + b.errors.inspect
        @blocked_bookings << b.service.name + " con " + b.service_provider.public_name + " el " + I18n.l(b.start.to_datetime)
      end
    end

    logger.debug "Llega a errors"
    logger.debug @errors.inspect

    if @errors.length > 0 and booking_data.length > 0
      if @errors.first.length > 0
        books = []
        @bookings.each do |b|
          if !b.id.nil?
            books << b
          end
        end
        redirect_to book_error_path(bookings: books.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: str_payment, blocked_bookings: @blocked_bookings)
        return
      end
    end

    if @bookings.length > 1
      if @session_booking.nil?
        Booking.send_multiple_booking_mail(@location_id, booking_group)
      else
        @session_booking.send_sessions_booking_mail
      end
    end

    logger.debug "Llega al final"

    @try_register = false
    @try_signin = false

    if !user_signed_in?
      if !User.find_by_email(params[:email])
        @try_register = true
        @user = User.new
        @user.email = params[:email]
        @user.first_name = params[:firstName]
        @user.last_name = params[:lastName]
        @user.phone = params[:phone]
      else
        @try_signin = true
      end
    end
    render layout: "workflow"
  end

  def book_error

    @try_register = false

    if params[:client] && params[:client] != ""

      if !Client.find(params[:client]).nil?

      @client = Client.find(params[:client])

        if !user_signed_in?
          if !User.find_by_email(@client.email)
            @try_register = true
            @user = User.new
            @user.email = @client.email
            @user.first_name = @client.first_name
            @user.last_name = @client.last_name
            @user.phone = @client.phone
          end
        end
      end

    end


    @location = Location.find(params[:location])
    @company = @location.company

    @tried_bookings = []
    if(params[:bookings])
      @tried_bookings = Booking.find(params[:bookings])
    end
    @payment = params[:payment]

    @blocked_bookings = []

    if params[:blocked_bookings]
      @blocked_bookings = params[:blocked_bookings]
    end
    @errors = params[:errors]
    @bookings = []

    @are_session_bookings = false
    if @tried_bookings.count > 0
      if @tried_bookings.first.is_session
        @are_session_bookings = true
      end
    end


    #If tried bookings where from service with sessions and promo, add just 1 to promo's max
    #Else, add 1 for each tried booking
    #In any case, delete all the bookings
    if @are_session_bookings
      session_booking = SessionBooking.find(@tried_bookings.first.session_booking_id)

      if !session_booking.treatment_promo_id.nil?
        treatment_promo = ServicePromo.find(session_booking.treatment_promo_id)
        treatment_promo.max_bookings = treatment_promo.max_bookings + 1
        treatment_promo.save
      end

      session_booking.delete

      @tried_bookings.each do |booking|
        booking.delete
      end

    else
      @tried_bookings.each do |booking|
        if !booking.service_promo_id.nil?
          service_promo = ServicePromo.find(booking.service_promo_id)
          service_promo.max_bookings = service_promo.max_bookings + 1
          service_promo.save
        end
        booking.delete
      end
    end

    #If payed, delete them all.
    # if @payment == "payment"
    #   if @are_session_bookings
    #     session_booking = SessionBooking.find(@tried_bookings.first.session_booking_id)

    #     if !session_booking.service_promo_id.nil?
    #       service_promo = ServicePromo.find(session_booking.service_promo_id)
    #       service_promo.max_bookings = service_promo.max_bookings + 1
    #       service_promo.save
    #     end

    #     session_booking.delete
    #   end
    #   @tried_bookings.each do |booking|
    #     booking.delete
    #   end
    # else #Create fake bookings and delete the real ones

    #   if !@are_session_bookings
    #     @tried_bookings.each do |booking|

    #         fake_booking = Booking.new(booking.attributes.to_options)
    #         @bookings << fake_booking
    #         booking.delete

    #     end
    #   else

    #     booked_correct = Booking.where(:id => params[:bookings]).where(:is_session_booked => true)
    #     service = @tried_bookings.first.service

    #     session_bookings = SessionBooking.where(:client_id => @tried_bookings.first.client_id)

    #     @tried_bookings.each do |booking|
    #       if booking.is_session_booked
    #         fake_booking = Booking.new(booking.attributes.to_options)
    #         fake_booking.session_booking_id = nil
    #         @bookings << fake_booking
    #       end
    #       booking.delete
    #     end

    #     session_bookings.each do |sb|
    #       if sb.bookings.count == 0
    #         sb.delete
    #       end
    #     end

    #   end
    # end

    host = request.host_with_port
    @url = @location.get_web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def remove_bookings
    @bookings = Booking.find(params[:bookings].split())
    @location = @bookings.first.location
    @company = Company.find(params[:company])
    @bookings.each do |booking|
      booking.destroy
    end

    # => Domain parser
    host = request.host_with_port
    @url = @location.get_web_address + '.' + host[host.index(request.domain)..host.length]

    flash[:notice] = "Reserva cancelada"
    redirect_to @url
  end

  def edit_booking
    require 'date'

    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    id = crypt.decrypt_and_verify(params[:confirmation_code])
    @booking = Booking.find(id)
    @company = Location.find(@booking.location_id).company
    @selectedLocation = Location.find(@booking.location_id)
    # => Domain parser
    host = request.host_with_port
    @url = @selectedLocation.get_web_address + '.' + host[host.index(request.domain)..host.length]

    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
    booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0
    if (booking_start <=> now) < 1 or @booking.max_changes <= 0
      redirect_to blocked_edit_path(:id => @booking.id)
      return
    end

    #Check if booking was part of a promo
    #If true, redirect to blocked_edit_path with the reason
    if @booking.check_for_promo_payment
      redirect_to blocked_edit_path(:id => @booking.id, :promo => true)
      return
    end

    #Revisar si fue pagada en línea.
    #Si lo fue, revisar política de modificación.
    if @booking.payed || !@booking.payed_booking.nil?
      if !@booking.is_session
        if !@company.company_setting.online_cancelation_policy.nil?
          ocp = @company.company_setting.online_cancelation_policy
          if !ocp.modifiable
            redirect_to blocked_edit_path(:id => @booking.id, :online => true)
            return
          else
            #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea

            #Mínimo
            book_start = DateTime.parse(@booking.start.to_s)
            min_hours = (book_start-now)/(60*60)
            min_hours = min_hours.to_i.abs

            if min_hours >= ocp.min_hours.to_i
              redirect_to blocked_edit_path(:id => @booking.id, :online => true)
                return
            end

            #Máximo
            booking_creation = DateTime.parse(@booking.created_at.to_s)
            minutes = (booking_creation.to_time - now.to_time)/(60)
            hours = (booking_creation.to_time - now.to_time)/(60*60)
            days = (booking_creation.to_time - now.to_time)/(60*60*24)
            minutes = minutes.to_i.abs
            hours = hours.to_i.abs
            days = days.to_i.abs
            weeks = days/7
            months = days/30

            #Obtener el máximo
            num = ocp.modification_max.to_i
            if ocp.modification_unit == TimeUnit.find_by_unit("Minutos").id
              if minutes >= num
                redirect_to blocked_edit_path(:id => @booking.id, :online => true)
                return
              end
            elsif ocp.modification_unit == TimeUnit.find_by_unit("Horas").id
              if hours >= num
                redirect_to blocked_edit_path(:id => @booking.id, :online => true)
                return
              end
            elsif ocp.modification_unit == TimeUnit.find_by_unit("Semanas").id
              if weeks >= num
                redirect_to blocked_edit_path(:id => @booking.id, :online => true)
                return
              end
            elsif ocp.modification_unit == TimeUnit.find_by_unit("Meses").id
              if months >= num
                redirect_to blocked_edit_path(:id => @booking.id, :online => true)
                return
              end
            end

          end
        end
      end
    end

    if mobile_request?
      @service = @booking.service
      @provider = @booking.service_provider
      @location = @booking.location
      cancelled_id = Status.find_by(name: 'Cancelado').id

      # Data
      @date = Date.parse(@booking.start.to_s)
      puts params[:datepicker]
      if !params[:datepicker].blank?
        @date = Date.parse(params[:datepicker])
      end
      service_duration = @service.duration
      company_setting = @company.company_setting
      provider_breaks = ProviderBreak.where(:service_provider_id => @provider.id)

      @available_time = Array.new

      # Variable Data
      provider_times = @provider.provider_times.where(day_id: @date.cwday).order(:open)
      bookings = @provider.bookings.where(:start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).order(:start)

      # Data
      provider = @booking.service_provider
      provider_breaks = provider.provider_breaks
      provider_times_first = provider.provider_times.order(:open).first
      provider_times_final = provider.provider_times.order(close: :desc).first

      # Block Hour
      # {
      #   status: 'available/occupied/empty/past',
      #   hour: {
      #     start: '10:00',
      #     end: '10:30',
      #     provider: ''
      #   }
      # }

      @available_time = Array.new

      # Variable Data
      day = @date.cwday
      provider_times = provider.provider_times.where(day_id: day).order(:open)

      if provider_times.length > 0

      provider_times_first_open = provider_times_first.open
      provider_times_final_close = provider_times_final.close

      provider_times_first_open_start = provider_times_first_open

      time_offset = 0

      while (provider_times_first_open_start <=> provider_times_final_close) < 0 do

        provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes

        status = 'empty'
        hour = {
          :start => '',
          :end => ''
        }

        available_provider = ''
        provider_time_valid = false
        provider_free = true
        provider_times.each do |provider_time|
          if (provider_time.open - provider_times_first_open_end)*(provider_times_first_open_start - provider_time.close) > 0
            if provider_time.open > provider_times_first_open_start
              time_offset += (provider_time.open - provider_times_first_open_start)/1.minutes
              if time_offset < service_duration
                provider_times_first_open_start = provider_time.open
                provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes
              end
            end
            if provider_time.open <= provider_times_first_open_start && provider_time.close >= provider_times_first_open_end
              provider_time_valid = true
            elsif provider_time.open <= provider_times_first_open_start
              time_offset = time_offset % service_duration
              provider_times_first_open_start -= time_offset.minutes
              provider_times_first_open_end -= time_offset.minutes
              time_offset = 0
            else
              provider_times_first_open_start -= time_offset.minutes
              provider_times_first_open_end -= time_offset.minutes
              time_offset = 0
            end
          end
          break if provider_time_valid
        end

        open_hour = provider_times_first_open_start.hour
        open_min = provider_times_first_open_start.min
        start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

        next_open_hour = provider_times_first_open_end.hour
        next_open_min = provider_times_first_open_end.min
        end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


        start_time_block = DateTime.new(@date.year, @date.mon, @date.mday, open_hour, open_min)
        end_time_block = DateTime.new(@date.year, @date.mon, @date.mday, next_open_hour, next_open_min)
        now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
        before_now = start_time_block - company_setting.before_booking / 24.0
        after_now = now + company_setting.after_booking * 30

        if provider_time_valid
          if (before_now <=> now) < 1
            status = 'past'
          elsif (after_now <=> end_time_block) < 1
            status = 'past'
          else
            status = 'occupied'
            Booking.where(:service_provider_id => provider.id, :start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |provider_booking|
              unless provider_booking.status_id == cancelled_id
                if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
                  if !@service.group_service || @service.id != provider_booking.service_id
                    if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
                      provider_free = false
                      break
                    end
                  elsif @service.group_service && @service.id == provider_booking.service_id && provider.bookings.where(:service_id => @service.id, :start => start_time_block).where.not(status_id: Status.find_by_name('Cancelado')).count >= @service.capacity
                    if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
                      provider_free = false
                      break
                    end
                  end
                end
              end
            end
            if @service.resources.count > 0
              @service.resources.each do |resource|
                if !@location.resource_locations.pluck(:resource_id).include?(resource.id)
                  provider_free = false
                  break
                end
                used_resource = 0
                group_services = []
                @location.bookings.where(:start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |location_booking|
                  if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
                    if location_booking.service.resources.include?(resource)
                      if !location_booking.service.group_service
                        used_resource += 1
                      else
                        if location_booking.service != @service || location_booking.service_provider != provider
                          group_services.push(location_booking.service_provider.id)
                        end
                      end
                    end
                  end
                end
                if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: @location.id).first.quantity
                  provider_free = false
                  break
                end
              end
            end
            ProviderBreak.where(:service_provider_id => provider.id).order(:start).each do |provider_break|
              if (provider_break.start.to_datetime - end_time_block)*(start_time_block - provider_break.end.to_datetime) > 0
                provider_free = false
              end
              break if !provider_free
            end

            if provider_free
              status = 'available'
              available_provider = provider.id
            end
          end
        end

        if ['past','available','occupied'].include? status
          hour = {
            :start => start_block,
            :end => end_block
          }
        end

        block_hour = Hash.new

        block_hour[:date] = @date
        block_hour[:hour] = hour
        block_hour[:provider] = available_provider

        @available_time << block_hour if status == 'available'
        provider_times_first_open_start = provider_times_first_open_end
      end
    end

    end

    render layout: "workflow"
  end

  def blocked_edit
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company
    @reason = "company"
    if params[:online]
      @reason = "online"
    elsif params[:promo]
      @reason = "promo"
    end
    # => Domain parser
    host = request.host_with_port
    @url = @booking.location.get_web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def edit_booking_post
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company
    @selectedLocation = Location.find(@booking.location_id)
    max_changes = @booking.max_changes - 1

    if @booking.check_for_promo_payment
      redirect_to blocked_edit_path(:id => @booking.id, :promo => true)
      return
    end

    if @booking.update(start: params[:start], end: params[:end], max_changes: max_changes)

      if @booking.is_session
        @booking.send_session_update_mail
      end

      current_user ? user = current_user.id : user = 0
      BookingHistory.create(booking_id: @booking.id, action: "Modificada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)
    else
      #flash[:alert] = "Hubo un error actualizando tu reserva. Inténtalo nuevamente."
      @errors = @booking.errors
    end

    # => Domain parser
    host = request.host_with_port
    @url = @selectedLocation.get_web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def confirm_booking
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    id = crypt.decrypt_and_verify(params[:confirmation_code])
    @booking = Booking.find(id)
    @selectedLocation = Location.find(@booking.location_id)
    @company = @selectedLocation.company

    status_confirmed = Status.find_by(:name => 'Confirmado')
    #status_reservado = Status.find_by_name('Reservado')
    #status_pagado = Status.find_by_name('Pagado')
    status_cancelado = Status.find_by_name('Cancelado')

    timezone = CustomTimezone.from_company(@company)
    if DateTime.now + timezone.offset > @booking.start || @booking.status_id == status_cancelado.id
        redirect_to confirm_error_path(:id => @booking.id)
        return
    end


    if @booking.update(:status => status_confirmed)
      current_user ? user = current_user.id : user = 0
      BookingHistory.create(booking_id: @booking.id, action: "Confirmada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)
    else
      redirect_to confirm_error_path(:id => @booking.id)
      return
    end

    redirect_to confirm_success_path(:id => @booking.id)
    return
  end

  def confirm_all_bookings
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    id = crypt.decrypt_and_verify(params[:confirmation_code])
    booking = Booking.find(id)
    @bookings = Booking.where(location_id: booking.location_id).where(reminder_group: booking.reminder_group)
    @company = Location.find(booking.location_id).company
    @selectedLocation = Location.find(booking.location_id)

    status_confirmed = Status.find_by(:name => 'Confirmado')
    status_cancelado = Status.find_by_name('Cancelado')

    timezone = CustomTimezone.from_company(@company)
    @bookings.each do |b|
      if DateTime.now + timezone.offset > b.start || b.status_id == status_cancelado.id

          if b.status_id == status_cancelado.id
            reason = "fue cancelada."
          else
            reason = "ya ocurrió."
          end

          redirect_to confirm_error_path(:id => @bookings.first.id, :group_confirm => true, :reason => reason)
          return
      end
    end

    @bookings.each do |b|
      if b.status_id != status_confirmed.id
        if b.update(:status => Status.find_by(:name => 'Confirmado'))
          current_user ? user = current_user.id : user = 0
          BookingHistory.create(booking_id: b.id, action: "Confirmada por Cliente", start: b.start, status_id: b.status_id, service_id: b.service_id, service_provider_id: b.service_provider_id, user_id: user, notes: b.notes, company_comment: b.company_comment)
        else
          redirect_to confirm_error_path(:id => @bookings.first.id, :group_confirm => true, :reason => "ocurrió un error inesperado.")
          return
        end
      end
    end
    redirect_to confirm_success_path(:id => @bookings.first.id, :group_confirm => true)
    return
  end

  def confirm_error
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company
    @selectedLocation = Location.find(@booking.location_id)
    @bookings = []
    if params[:group_confirm]
      @bookings = Booking.where(location_id: @booking.location_id).where(reminder_group: @booking.reminder_group)
      @reason = params[:reason]
    end
    render layout: 'workflow'
  end

  def confirm_success
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company
    @selectedLocation = Location.find(@booking.location_id)
    @bookings = []
    if params[:group_confirm]
      @bookings = Booking.where(location_id: @booking.location_id).where(reminder_group: @booking.reminder_group)
    end
    render layout: 'workflow'
  end

  def blocked_cancel
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company
    @reason = "company"
    if params[:promo]
      @reason = "promo"
    elsif params[:online]
      @reason = "online"
      if !params[:only_booking].nil? and params[:only_booking]
        @reason = "only_booking"
      end
    end
    # => Domain parser
    host = request.host_with_port
    @url = @booking.location.get_web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def cancel_booking
    require 'date'

    unless params[:id]
      crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
      id = crypt.decrypt_and_verify(params[:confirmation_code])
      @booking = Booking.find(id)
      @company = Location.find(@booking.location_id).company
      @selectedLocation = Location.find(@booking.location_id)

      now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
      booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0

      if (booking_start <=> now) < 1
        redirect_to blocked_cancel_path(:id => @booking.id)
        return
      end

      #Check if booking was part of a promo
      #If true, redirect to cancel_block_path with reason
      if @booking.check_for_promo_payment
        redirect_to blocked_cancel_path(:id => @booking.id, :promo => true)
        return
      end

      # Revisar si fue pagada en línea.
      # Si lo fue, revisar política de modificación.
      if @booking.payed || !@booking.payed_booking.nil?
        if !@booking.is_session
          if !@company.company_setting.online_cancelation_policy.nil?
            ocp = @company.company_setting.online_cancelation_policy
            if !ocp.cancelable
              redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
              return
            else

              # No permitir cancelar una particular si fueron pagadas varias juntas.
              # Puede cancelar todas o ninguna.
              if @booking.payed_booking.bookings.count > 1
                redirect_to blocked_cancel_path(:id => @booking.id, :online => true, :only_booking => true)
                return
              end

              #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea
              #Mínimo
              book_start = DateTime.parse(@booking.start.to_s)
              min_hours = (book_start-now)/(60*60)
              min_hours = min_hours.to_i.abs

              if min_hours >= ocp.min_hours.to_i
                redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
              end

              #Máximo
              booking_creation = DateTime.parse(@booking.created_at.to_s)
              minutes = (booking_creation.to_time - now.to_time)/(60)
              hours = (booking_creation.to_time - now.to_time)/(60*60)
              days = (booking_creation.to_time - now.to_time)/(60*60*24)
              minutes = minutes.to_i.abs
              hours = hours.to_i.abs
              days = days.to_i.abs
              weeks = days/7
              months = days/30

              #Obtener el máximo
              num = ocp.cancel_max.to_i
              if ocp.cancel_unit == TimeUnit.find_by_unit("Minutos").id
                if minutes >= num
                  redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
                end
              elsif ocp.cancel_unit == TimeUnit.find_by_unit("Horas").id
                if hours >= num
                  redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
                end
              elsif ocp.cancel_unit == TimeUnit.find_by_unit("Semanas").id
                if weeks >= num
                  redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
                end
              elsif ocp.cancel_unit == TimeUnit.find_by_unit("Meses").id
                if months >= num
                  redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
                end
              end

            end
          end
        end
      end

      # status = Status.find_by(:name => 'Cancelado').id

      # payed = false

      # if @booking.update(status_id: status, payed: payed)

      #   if !@booking.payed_booking.nil?
      #     @booking.payed_booking.canceled = true
      #     @booking.payed_booking.save
      #   end
      #   #flash[:notice] = "Reserva cancelada exitosamente."
      #   # BookingMailer.cancel_booking(@booking)
      #   current_user ? user = current_user.id : user = 0
      #   BookingHistory.create(booking_id: @booking.id, action: "Cancelada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user)
      # else
      #   flash[:alert] = "Hubo un error cancelando tu reserva. Inténtalo nuevamente."
      #   @errors = @booking.errors
      # end

    else

      @booking = Booking.find(params[:id])


      @company = Location.find(@booking.location_id).company
      @selectedLocation = Location.find(@booking.location_id)

      now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
      booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0

      if (booking_start <=> now) < 1
        redirect_to blocked_cancel_path(:id => @booking.id)
        return
      end

      #Revisar si fue pagada en línea.
      #Si lo fue, revisar política de modificación.
      if @booking.payed || !@booking.payed_booking.nil?
        if !@booking.is_session
          if !@company.company_setting.online_cancelation_policy.nil?
            ocp = @company.company_setting.online_cancelation_policy
            if !ocp.cancelable
              redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
              return
            else
              #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea

              #Mínimo
              book_start = DateTime.parse(@booking.start.to_s)
              min_hours = (book_start-now)/(60*60)
              min_hours = min_hours.to_i.abs

              if min_hours >= ocp.min_hours.to_i
                redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
              end

              #Máximo
              booking_creation = DateTime.parse(@booking.created_at.to_s)
              minutes = (booking_creation.to_time - now.to_time)/(60)
              hours = (booking_creation.to_time - now.to_time)/(60*60)
              days = (booking_creation.to_time - now.to_time)/(60*60*24)
              minutes = minutes.to_i.abs
              hours = hours.to_i.abs
              days = days.to_i.abs
              weeks = days/7
              months = days/30

              #Obtener el máximo
              num = ocp.cancel_max.to_i
              if ocp.cancel_unit == TimeUnit.find_by_unit("Minutos").id
                if minutes >= num
                  redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
                end
              elsif ocp.cancel_unit == TimeUnit.find_by_unit("Horas").id
                if hours >= num
                  redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
                end
              elsif ocp.cancel_unit == TimeUnit.find_by_unit("Semanas").id
                if weeks >= num
                  redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
                end
              elsif ocp.cancel_unit == TimeUnit.find_by_unit("Meses").id
                if months >= num
                  redirect_to blocked_cancel_path(:id => @booking.id, :online => true)
                  return
                end
              end

            end
          end
        end
      end

      status = @booking.status.id
      payed = @booking.payed
      is_booked = @booking.is_session_booked
      if !@booking.is_session
        status = Status.find_by(:name => 'Cancelado').id
        payed = false
      else
        is_booked = false
      end

      if @booking.update(status_id: status, payed: payed, is_session_booked: is_booked)

        if !@booking.payed_booking.nil?
          @booking.payed_booking.canceled = true
          @booking.payed_booking.save
        end
        #flash[:notice] = "Reserva cancelada exitosamente."
        # BookingMailer.cancel_booking(@booking)
        current_user ? user = current_user.id : user = 0
        BookingHistory.create(booking_id: @booking.id, action: "Cancelada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)
      else
        flash[:alert] = "Hubo un error cancelando tu reserva. Inténtalo nuevamente."
        @errors = @booking.errors
      end

    end

    @company = Location.find(@booking.location_id).company

    # => Domain parser
    host = request.host_with_port
    @url = @selectedLocation.get_web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: 'workflow'
  end

  def cancel_all_reminded_booking
    require 'date'

    unless params[:id]
      crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
      id = crypt.decrypt_and_verify(params[:confirmation_code])
      @booking = Booking.find(id)
      @company = Location.find(@booking.location_id).company
      @bookings = Booking.where(location_id: @booking.location_id).where(reminder_group: @booking.reminder_group)
      @selectedLocation = Location.find(@booking.location_id)

      now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)

      #Pagadas

      if @booking.check_for_promo_payment
        redirect_to blocked_cancel_path(:id => @booking.id, :promo => true)
        return
      end

      #Revisar si fue pagada en línea.
      #Si lo fue, revisar política de modificación.
      @bookings.each do |booking|
        if booking.payed || !booking.payed_booking.nil?

          if !booking.is_session
            if !@company.company_setting.online_cancelation_policy.nil?
              ocp = @company.company_setting.online_cancelation_policy
              if !ocp.cancelable
                redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                return
              else
                #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea

                #Mínimo
                book_start = DateTime.parse(booking.start.to_s)
                min_hours = (book_start-now)/(60*60)
                min_hours = min_hours.to_i.abs

                if min_hours >= ocp.min_hours.to_i
                  redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                end

                #Máximo
                booking_creation = DateTime.parse(booking.created_at.to_s)
                minutes = (booking_creation.to_time - now.to_time)/(60)
                hours = (booking_creation.to_time - now.to_time)/(60*60)
                days = (booking_creation.to_time - now.to_time)/(60*60*24)
                minutes = minutes.to_i.abs
                hours = hours.to_i.abs
                days = days.to_i.abs
                weeks = days/7
                months = days/30

                #Obtener el máximo
                num = ocp.cancel_max.to_i
                if ocp.cancel_unit == TimeUnit.find_by_unit("Minutos").id
                  if minutes >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Horas").id
                  if hours >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Semanas").id
                  if weeks >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Meses").id
                  if months >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                end

              end
            end
          end

        end

        booking_start = DateTime.parse(booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0

        if (booking_start <=> now) < 1
          flash[:alert] = "No fue posible cancelar"
          redirect_to root_path
          return
        end

      end
      #Fin pagadas

      # else
      #   status = Status.find_by(:name => 'Cancelado').id
      #   @bookings.each do |book|
      #     if book.update(status_id: status)
      #       current_user ? user = current_user.id : user = 0
      #       BookingHistory.create(booking_id: book.id, action: "Cancelada por Cliente", start: book.start, status_id: book.status_id, service_id: book.service_id, service_provider_id: book.service_provider_id, user_id: user)
      #     end
      #   end
      # end

    else
      booking = Booking.find(params[:id])
      @company = Location.find(booking.location_id).company
      @bookings = Booking.where(location_id: booking.location_id).where(reminder_group: booking.reminder_group)
      @selectedLocation = Location.find(booking.location_id)
      status = Status.find_by(:name => 'Cancelado').id
      were_payed = true

      @bookings.each do |booking|
        if booking.payed || !booking.payed_booking.nil?

          if !booking.is_session
            if !@company.company_setting.online_cancelation_policy.nil?
              ocp = @company.company_setting.online_cancelation_policy
              if !ocp.cancelable
                redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                return
              else
                #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea
                now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
                #Mínimo
                book_start = DateTime.parse(booking.start.to_s)
                min_hours = (book_start-now)/(60*60)
                min_hours = min_hours.to_i.abs

                if min_hours >= ocp.min_hours.to_i
                  redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                end

                #Máximo
                booking_creation = DateTime.parse(booking.created_at.to_s)
                minutes = (booking_creation.to_time - now.to_time)/(60)
                hours = (booking_creation.to_time - now.to_time)/(60*60)
                days = (booking_creation.to_time - now.to_time)/(60*60*24)
                minutes = minutes.to_i.abs
                hours = hours.to_i.abs
                days = days.to_i.abs
                weeks = days/7
                months = days/30

                #Obtener el máximo
                num = ocp.cancel_max.to_i
                if ocp.cancel_unit == TimeUnit.find_by_unit("Minutos").id
                  if minutes >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Horas").id
                  if hours >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Semanas").id
                  if weeks >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Meses").id
                  if months >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                end

              end
            end
          end

        else
          were_payed = false
        end
      end
      #Fin pagadas

      success = true
      are_session_bookings = true
      @bookings.each do |book|

        is_booked = book.is_session_booked

        if book.is_session
          is_booked = false
          status = book.status.id
        else
          are_session_bookings = false
        end
        if book.update(status_id: status, is_session_booked: is_booked)
          current_user ? user = current_user.id : user = 0
          BookingHistory.create(booking_id: book.id, action: "Cancelada por Cliente", start: book.start, status_id: book.status_id, service_id: book.service_id, service_provider_id: book.service_provider_id, user_id: user, notes: book.notes, company_comment: book.company_comment)
        else
          success = false
        end

      end

      if success && were_payed && !are_session_bookings
        payed_booking = @bookings.first.payed_booking
        BookingMailer.cancel_payment_mail(payed_booking, 1)
        BookingMailer.cancel_payment_mail(payed_booking, 2)
        BookingMailer.cancel_payment_mail(payed_booking, 3)
      end

    end

    # => Domain parser
    host = request.host_with_port
    @url = @selectedLocation.get_web_address + '.' + host[host.index(request.domain)..host.length]
    render layout: 'workflow'
  end

  def cancel_all_booking
    require 'date'

    unless params[:id]
      crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
      id = crypt.decrypt_and_verify(params[:confirmation_code])
      @booking = Booking.find(id)
      @company = Location.find(@booking.location_id).company
      @bookings = Booking.where(location: @booking.location).where(booking_group: @booking.booking_group)
      @selectedLocation = Location.find(@booking.location_id)

      now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)

      #Pagadas

      if @booking.check_for_promo_payment
        redirect_to blocked_cancel_path(:id => @booking.id, :promo => true)
        return
      end

      #Revisar si fue pagada en línea.
      #Si lo fue, revisar política de modificación.
      @bookings.each do |booking|
        if booking.payed || !booking.payed_booking.nil?

          if !booking.is_session
            if !@company.company_setting.online_cancelation_policy.nil?
              ocp = @company.company_setting.online_cancelation_policy
              if !ocp.cancelable
                redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                return
              else
                #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea

                #Mínimo
                book_start = DateTime.parse(booking.start.to_s)
                min_hours = (book_start-now)/(60*60)
                min_hours = min_hours.to_i.abs

                if min_hours >= ocp.min_hours.to_i
                  redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                end

                #Máximo
                booking_creation = DateTime.parse(booking.created_at.to_s)
                minutes = (booking_creation.to_time - now.to_time)/(60)
                hours = (booking_creation.to_time - now.to_time)/(60*60)
                days = (booking_creation.to_time - now.to_time)/(60*60*24)
                minutes = minutes.to_i.abs
                hours = hours.to_i.abs
                days = days.to_i.abs
                weeks = days/7
                months = days/30

                #Obtener el máximo
                num = ocp.cancel_max.to_i
                if ocp.cancel_unit == TimeUnit.find_by_unit("Minutos").id
                  if minutes >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Horas").id
                  if hours >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Semanas").id
                  if weeks >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Meses").id
                  if months >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                end

              end
            end
          end

        end

        booking_start = DateTime.parse(booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0

        if (booking_start <=> now) < 1
          flash[:alert] = "No fue posible cancelar"
          redirect_to root_path
          return
        end

      end
      #Fin pagadas

      # else
      #   status = Status.find_by(:name => 'Cancelado').id
      #   @bookings.each do |book|
      #     if book.update(status_id: status)
      #       current_user ? user = current_user.id : user = 0
      #       BookingHistory.create(booking_id: book.id, action: "Cancelada por Cliente", start: book.start, status_id: book.status_id, service_id: book.service_id, service_provider_id: book.service_provider_id, user_id: user)
      #     end
      #   end
      # end

    else
      booking = Booking.find(params[:id])
      @company = Location.find(booking.location_id).company
      @bookings = Booking.where(location: booking.location).where(booking_group: booking.booking_group)
      @selectedLocation = Location.find(booking.location_id)
      status = Status.find_by(:name => 'Cancelado').id
      were_payed = true

      @bookings.each do |booking|
        if booking.payed || !booking.payed_booking.nil?

          if !booking.is_session
            if !@company.company_setting.online_cancelation_policy.nil?
              ocp = @company.company_setting.online_cancelation_policy
              if !ocp.cancelable
                redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                return
              else
                #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea
                now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
                #Mínimo
                book_start = DateTime.parse(booking.start.to_s)
                min_hours = (book_start-now)/(60*60)
                min_hours = min_hours.to_i.abs

                if min_hours >= ocp.min_hours.to_i
                  redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                end

                #Máximo
                booking_creation = DateTime.parse(booking.created_at.to_s)
                minutes = (booking_creation.to_time - now.to_time)/(60)
                hours = (booking_creation.to_time - now.to_time)/(60*60)
                days = (booking_creation.to_time - now.to_time)/(60*60*24)
                minutes = minutes.to_i.abs
                hours = hours.to_i.abs
                days = days.to_i.abs
                weeks = days/7
                months = days/30

                #Obtener el máximo
                num = ocp.cancel_max.to_i
                if ocp.cancel_unit == TimeUnit.find_by_unit("Minutos").id
                  if minutes >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Horas").id
                  if hours >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Semanas").id
                  if weeks >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                elsif ocp.cancel_unit == TimeUnit.find_by_unit("Meses").id
                  if months >= num
                    redirect_to blocked_cancel_path(:id => booking.id, :online => true)
                    return
                  end
                end

              end
            end
          end

        else
          were_payed = false
        end
      end
      #Fin pagadas

      success = true
      are_session_bookings = true
      @bookings.each do |book|

        is_booked = book.is_session_booked

        if book.is_session
          is_booked = false
          status = book.status.id
        else
          are_session_bookings = false
        end
        if book.update(status_id: status, is_session_booked: is_booked)
          current_user ? user = current_user.id : user = 0
          BookingHistory.create(booking_id: book.id, action: "Cancelada por Cliente", start: book.start, status_id: book.status_id, service_id: book.service_id, service_provider_id: book.service_provider_id, user_id: user, notes: book.notes, company_comment: book.company_comment)
        else
          success = false
        end

      end

      if success && were_payed && !are_session_bookings
        payed_booking = @bookings.first.payed_booking
        BookingMailer.cancel_payment_mail(payed_booking, 1)
        BookingMailer.cancel_payment_mail(payed_booking, 2)
        BookingMailer.cancel_payment_mail(payed_booking, 3)
      end

    end

    # => Domain parser
    host = request.host_with_port
    @url = @selectedLocation.get_web_address + '.' + host[host.index(request.domain)..host.length]
    render layout: 'workflow'
  end

  def transfer_error_cancel
    if params[:company_id]
      @company = Company.find(params[:company_id])
      render layout: 'workflow'
    else
      redirect_to root_url(subdomain: false)
      return
    end
  end

  def check_user_cross_bookings
    require 'date'
    if !params[:user_id].blank?
      bookings = Booking.where(:user_id => params[:user_id], :status_id => [Status.find_by(:name => 'Reservado'), Status.find_by(:name => 'Confirmado')])
      booking_start = DateTime.parse(params[:booking_start])
      booking_end = DateTime.parse(params[:booking_end])
      bookings.each do |booking|
        book_start = DateTime.parse(booking.start.to_s)
        book_end = DateTime.parse(booking.end.to_s)
        if !(booking_end <= book_start || book_end <= booking_start)
          if !booking.is_session || (booking.is_session && booking.is_session_booked)
            render :json => {
              :crossover => true,
              :booking => {
                :service => booking.service.name,
                :service_provider => booking.service_provider.public_name,
                :start => booking.start,
                :end => booking.end
              }
            }
          end
          return
        end
      end
    end
    render :json => {:crossover => false}
  end

  def provider_hours
    @service_provider = ServiceProvider.find(params[:service_provider_id])
    @use_identification_number = @service_provider.company.company_setting.use_identification_number
    block_length = @service_provider.block_length * 60
    now = params[:provider_date].to_date
    table_rows = []

    provider_times = @service_provider.provider_times.where(day_id: now.cwday).order(:open)

    if provider_times.length > 0

      open_provider_time = provider_times.first.open
      close_provider_time = provider_times.last.close

      provider_open = provider_times.first.open

      Booking.where('bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)').where(service_provider: @service_provider, status_id: Status.where(name: ['Reservado', 'Confirmado','Asiste']).pluck(:id)).where('bookings.start >= ? AND bookings.start < ?', now.beginning_of_day, DateTime.new(now.year, now.mon, now.mday, open_provider_time.hour, open_provider_time.min)).order(:start).each do |booking|
        if @use_identification_number
          table_rows.append([booking.start.strftime('%R'), booking.client.first_name + ' ' + booking.client.last_name, booking.client.phone, booking.client.identification_number, booking.service.name, booking.status.name])
        else
          table_rows.append([booking.start.strftime('%R'), booking.client.first_name + ' ' + booking.client.last_name, booking.client.phone, booking.service.name, booking.status.name])
        end
      end
      while (provider_open <=> close_provider_time) < 0 do
        provider_close = provider_open + block_length

        table_row = [provider_open.strftime('%R'), nil, nil, nil, nil]
        last_row = table_rows.length - 1

        block_open = DateTime.new(now.year, now.mon, now.mday, provider_open.hour, provider_open.min)
        block_close = DateTime.new(now.year, now.mon, now.mday, provider_close.hour, provider_close.min)

        service_name = 'Descanso por Horario'
        booking_status = '...'
        client_name = '...'
        client_phone = '...'
        client_identification = '...'

        in_provider_time = false
        provider_times.each do |provider_time|
          if (provider_time.open - provider_close)*(provider_open - provider_time.close) > 0
            in_provider_time = true
            booking_status = ''
            service_name = ''
            client_name = ''
            client_phone = ''
            client_identification = ''
            break
          end
        end
        in_provider_booking = false
            # if in_provider_time
              Booking.where('bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)').where(service_provider: @service_provider, status_id: Status.where(name: ['Reservado', 'Confirmado','Asiste']).pluck(:id)).where('bookings.start >= ? AND bookings.start < ?', block_open, block_close).order(:start).each do |booking|
                  in_provider_booking = true
                  if @use_identification_number
              table_rows.append([booking.start.strftime('%R'), booking.client.first_name + ' ' + booking.client.last_name, booking.client.phone, booking.client.identification_number, booking.service.name, booking.status.name])
            else
              table_rows.append([booking.start.strftime('%R'), booking.client.first_name + ' ' + booking.client.last_name, booking.client.phone, booking.service.name, booking.status.name])
            end
              end
            # end
            in_provider_break = false
            if in_provider_time && !in_provider_booking
              ProviderBreak.where(service_provider: @service_provider, start: now.beginning_of_day..now.end_of_day).each do |provider_break|
                if (provider_break.start.to_datetime - block_close)*(block_open - provider_break.end.to_datetime) > 0
                    in_provider_booking = true
                    service_name = "Bloqueo: "+provider_break.name
                    booking_status = '...'
            client_name = '...'
            client_phone = '...'
            client_identification = '...'
            if @use_identification_number
              table_rows.append([provider_break.start.strftime('%R'), service_name, client_name, client_phone, client_identification, 'Bloqueado'])
            else
                      table_rows.append([provider_break.start.strftime('%R'), service_name, client_name, client_phone, 'Bloqueado'])
            end
                    break
                end
              end
            end

            if in_provider_time

              if last_row >= 0
                while table_rows[last_row][1] == 'Continuación...'  do
                  # Subir un nivel para ver si es el mismo servicio o no
                    last_row -=1
                end

                if !in_provider_booking
                  Booking.where('bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)').where(service_provider: @service_provider, status_id: Status.where(name: ['Reservado', 'Confirmado','Asiste']).pluck(:id), start: now.beginning_of_day..now.end_of_day).order(:start).each do |booking|
                    if (booking.start.to_datetime - block_close)*(block_open - booking.end.to_datetime) > 0
                      in_provider_booking = true
                      if @use_identification_number
              table_rows.append([provider_open.strftime('%R'), 'OCUPADO', '...', '...', '...', '...'])
              else
                          table_rows.append([provider_open.strftime('%R'), 'OCUPADO', '...', '...', '...'])
              end
                      break
                    end
                  end
                end

                # if (service_name != '') && (service_name == table_rows[last_row][1]) && (client_name == (table_rows[last_row][2]))

                #   service_name = 'OCUPADO'
                #   client_name = '...'
                #   client_phone = '...'


                # end
              end
            end

            if !in_provider_booking
              table_row << service_name
              table_row << booking_status
              table_row << client_name
              table_row << client_phone
              if @use_identification_number
                table_row << client_identification
              end
              table_row.compact!

              table_rows.append(table_row)
            end

        provider_open += block_length
      end
      Booking.where('bookings.is_session = false OR (bookings.is_session = true AND bookings.is_session_booked = true)').where(service_provider: @service_provider, status_id: Status.where(name: ['Reservado', 'Confirmado','Asiste']).pluck(:id), start: DateTime.new(now.year, now.mon, now.mday, close_provider_time.hour, close_provider_time.min)..now.end_of_day).order(:start).each do |booking|
        if @use_identification_number
          table_rows.append([booking.start.strftime('%R'), booking.client.first_name + ' ' + booking.client.last_name, booking.client.phone, booking.client.identification_number, booking.service.name, booking.status.name])
        else
          table_rows.append([booking.start.strftime('%R'), booking.client.first_name + ' ' + booking.client.last_name, booking.client.phone, booking.service.name, booking.status.name])
        end
      end
    end
    respond_to do |format|
      format.json { render :json => table_rows }
    end
  end

  def block_promotion_hours

  end

  def promotion_hours

    week_days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
    require 'date'

    local = Location.find(params[:local])
    company_setting = local.company.company_setting
    cancelled_id = Status.find_by(name: 'Cancelado').id
    serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
    session_booking = nil

    if params[:session_booking_id] && params[:session_booking_id] != ""
      session_booking = SessionBooking.find(params[:session_booking_id])
    end

    if params[:date] && params[:date] != ""
      current_date = params[:date]
    else
      current_date = DateTime.now.to_date.to_s
    end

    weekDate = Date.strptime(current_date, '%Y-%m-%d')

    #logger.debug "current_date: " + current_date.to_s
    #logger.debug "weekDate: " + weekDate.to_s

    if params[:date] and params[:date] != ""
      if params[:date].to_datetime > now
        now = params[:date].to_datetime
      end
    end

    #logger.debug "now: " + now.to_s

    days_ids = [1,2,3,4,5,6,7]
    index = days_ids.find_index(now.cwday)
    ordered_days = days_ids[index, days_ids.length] + days_ids[0, index]

    day_positive_gaps = [0,0,0,0,0,0,0]

    @days_count = 0
    @week_blocks = []
    @days_row = []

    book_index = 0
    book_summaries = []

    total_hours_array = []

    loop_times = 0

    max_time_diff = 0

    #Save first service and it's providers for later use

    first_service = Service.find(serviceStaff[0][:service])
    first_providers = []
    if serviceStaff[0][:provider] != "0"
      first_providers << ServiceProvider.find(serviceStaff[0][:provider])
    else

      first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(:order, :public_name)

      if first_providers.count == 0
        first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true).order(:order, :public_name)
      end

    end

    #Look for services and providers and save them for later use.
    #Also, save total services duration

    total_services_duration = 0

    #False if last tried block allocation failed.
    #Used for searching gaps. They should be looked for only if last block culd be allocated,
    #because if not, then there isn't anyway that coming back in time cause correct allocation.
    last_check = false

    #Checks if the block being allocated is from a gap
    is_gap_hour = false

    #Holds current_gap to sum a day's total gap and adjust calendar's height
    current_gap = 0

    services_arr = []
    bundles_arr = []
    providers_arr = []
    for i in 0..serviceStaff.length-1
      services_arr[i] = Service.find(serviceStaff[i][:service])
      bundles_arr[i] = Bundle.find_by(id: serviceStaff[i][:bundle_id])
      total_services_duration += services_arr[i].duration
      if serviceStaff[i][:provider] != "0"
        providers_arr[i] = []
        providers_arr[i] << ServiceProvider.find(serviceStaff[i][:provider])
      else
        providers_arr[i] = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true)
        if providers_arr[i].count == 0
          providers_arr[i] = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true)
        end
      end
    end

    #providers_arr = []
    #for i

    after_date = DateTime.now + company_setting.after_booking.months

    weekDate.upto(weekDate + 6) do |date|

      day = date.cwday
      dtp = local.location_times.where(day_id: day).order(:open).first
      if dtp.nil?
        #logger.debug "Nil day " + day.to_s
        next
      end




      dateTimePointer = dtp.open

      dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
      day_open_time = dateTimePointer

      dateTimePointerEnd = dateTimePointer


      if date > after_date
        break
      end

      hours_array = []

      day_close = local.location_times.where(day_id: day).order(:close).first.close
      limit_date = DateTime.new(date.year, date.mon, date.mday, day_close.hour, day_close.min)

      while (dateTimePointer < limit_date)

        #logger.debug "DTP: " + dateTimePointer.to_s

        serviceStaffPos = 0
        bookings = []

        while serviceStaffPos < serviceStaff.length and (dateTimePointer < limit_date)


          #if !first_service.company.company_setting.allows_optimization
          #  if dateTimePointerEnd > dateTimePointer
          #    logger.debug "Entra acá"
          #    dateTimePointer += first_service.company.company_setting.calendar_duration.minutes
          #    next
          #  end
          #end

          service_valid = false
          #service = Service.find(serviceStaff[serviceStaffPos][:service])
          service = services_arr[serviceStaffPos]
          bundle = bundles_arr[serviceStaffPos]

          current_service_providers = ServiceProvider.where(active: true, online_booking: true, :location_id => local.id, :id => ServiceStaff.where(:service_id => service.id).pluck(:service_provider_id))

          if current_service_providers.count == 0
            current_service_providers = ServiceProvider.where(active: true, :location_id => local.id, :id => ServiceStaff.where(:service_id => service.id).pluck(:service_provider_id))
          end

          #Get providers min
          min_pt = ProviderTime.where(:service_provider_id => current_service_providers.pluck(:id)).where(day_id: day).order(:open).first

          # logger.debug "MIN PROVIDER TIME: " + min_pt.open.strftime("%H:%M")
          # logger.debug "DATE TIME POINTER: " + dateTimePointer.strftime("%H:%M")

          if !min_pt.nil? && min_pt.open.strftime("%H:%M") > dateTimePointer.strftime("%H:%M")
            #logger.debug "Changing dtp"
            dateTimePointer = min_pt.open
            dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
            day_open_time = dateTimePointer
          end

          #To deattach continous services, just delete the serviceStaffPos condition


          #Uncomment for overlaping hours

          #if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization && last_check
          #  dateTimePointer = dateTimePointer - total_services_duration.minutes + first_service.company.company_setting.calendar_duration.minutes
          #end

          if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization
            #Calculate offset
            offset_diff = (dateTimePointer-day_open_time)*24*60
            offset_rem = offset_diff % first_service.company.company_setting.calendar_duration
            if offset_rem != 0
              dateTimePointer = dateTimePointer + (first_service.company.company_setting.calendar_duration - offset_rem).minutes
            end
          end

          #Find next service block starting from dateTimePointer
          service_sum = service.duration.minutes

          minHour = now
          #logger.debug "min_hours: " + minHour.to_s
          if !params[:admin] && minHour <= DateTime.now
            minHour += company_setting.before_booking.hours
          end
          if dateTimePointer >= minHour
            service_valid = true
          end

          #logger.debug "min_hours: " + minHour.to_s

          # Hora dentro del horario del local

          #if service_valid
          #  service_valid = false
          #  for
          #end

          if service_valid
            service_valid = false
            local.location_times.where(day_id: dateTimePointer.cwday).each do |times|
              location_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.open.hour, times.open.min)
              location_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.close.hour, times.close.min)

              if location_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= location_close
                service_valid = true
                break
              end
            end
          end

          # Horario dentro del horario del provider
          if service_valid

            # Service Time Restricted
            if service.time_restricted
              service_valid = false
              service.service_times.where(day_id: dateTimePointer.cwday).each do |times|
                service_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.open.hour, times.open.min)
                service_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.close.hour, times.close.min)

                if service_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= service_close
                  service_valid = true
                  break
                end
              end
            end

            # Elegible Providers
            providers = []
            if service_valid
              if serviceStaff[serviceStaffPos][:provider] != "0"
                providers << ServiceProvider.find(serviceStaff[serviceStaffPos][:provider])
                #providers = providers_arr[serviceStaffPos]
              else

                #Check if providers have same day open
                #If they do, choose the one with less ocupations to start with
                #If they don't, choose the one that starts earlier.
                if service.check_providers_day_times(dateTimePointer)

                  providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }

                  if providers.count == 0
                    providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }
                  end

                  #providers = providers_arr[serviceStaffPos].order(:order, :public_name).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }

                else

                  providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(order: :asc).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }

                  if providers.count == 0
                    providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true).order(order: :asc).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }
                  end

                  #providers = providers_arr[serviceStaffPos].order(:order, :public_name).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }
                end
              end
            end

            providers.each do |provider|

              provider_min_pt = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first
              if !provider_min_pt.nil? && dateTimePointer.strftime("%H:%M") < provider_min_pt.open.strftime("%H:%M")
                dateTimePointer = provider_min_pt.open
                dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
                #dateTimePointer = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open.to_datetime
              end

              service_valid = false

              #Check directly on query instead of looping through

              provider.provider_times.where(day_id: dateTimePointer.cwday).each do |provider_time|
                provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
                provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

                if provider_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= provider_close
                  service_valid = true
                  break
                end
              end

              # #Stored procedure for time check

              # proc_start_date = dateTimePointer.to_s.gsub('T', ' ')
              # proc_end_date = dateTimePointer + service.duration.minutes
              # proc_end_date = proc_end_date.to_s.gsub('T', ' ')

              # if ActiveRecord::Base.connection.execute("select check_hour(#{local.id}, #{provider.id}, #{service.id}, '#{proc_start_date}', '#{proc_end_date}')")[0]['check_hour'] == 't'
              #   service_valid = true
              # else
              #   service_valid = false
              # end

              # Provider breaks
              if service_valid

                if provider.provider_breaks.where.not('(provider_breaks.end <= ? or ? <= provider_breaks.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
                  service_valid = false
                end

              end

              # Cross Booking
              if service_valid

                if !service.group_service
                  if Booking.where(service_provider_id: provider.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
                    service_valid = false
                  end
                else

                  #Check for services that aren't the searched one, then check for capacity of this one
                  if Booking.where(service_provider_id: provider.id).where.not(service_id: service.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
                    service_valid = false
                  end

                  if Booking.where(service_provider_id: provider.id, service_id: service.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count >= service.capacity
                    service_valid = false
                  end

                end


              end

              # Recursos
              if service_valid and service.resources.count > 0
                service.resources.each do |resource|
                  if !local.resource_locations.pluck(:resource_id).include?(resource.id)
                    service_valid = false
                    break
                  end
                  used_resource = 0
                  group_services = []
                  pointerEnd = dateTimePointer+service.duration.minutes
                  local.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
                    if location_booking.status_id != cancelled_id && !(pointerEnd <= location_booking.start.to_datetime || location_booking.end.to_datetime <= dateTimePointer)
                      if location_booking.service.resources.include?(resource)
                        if !location_booking.service.group_service
                          used_resource += 1
                        else
                          if location_booking.service != service || location_booking.service_provider != provider
                            group_services.push(location_booking.service_provider.id)
                          end
                        end
                      end
                    end
                  end
                  if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: local.id).first.quantity
                    service_valid = false
                    break
                  end
                end
              end

              if service_valid

                book_sessions_amount = 0
                if service.has_sessions
                  book_sessions_amount = service.sessions_amount
                end

                bookings << {
                  :service => service.id,
                  :provider => provider.id,
                  :start => dateTimePointer,
                  :end => dateTimePointer + service.duration.minutes,
                  :service_name => service.name,
                  :provider_name => provider.public_name,
                  :provider_lock => serviceStaff[serviceStaffPos][:provider] != "0",
                  :provider_id => provider.id,
                  :price => service.price,
                  :online_payable => service.online_payable,
                  :has_discount => service.has_discount,
                  :discount => service.discount,
                  :show_price => service.show_price && bundle.blank?,
                  :has_time_discount => service.has_time_discount,
                  :has_sessions => service.has_sessions,
                  :sessions_amount => book_sessions_amount,
                  :must_be_paid_online => service.must_be_paid_online,
                  :bundled => bundle.present?,
                  :bundle_id => bundle.present? ? bundle.id : nil
                }

                if !service.online_payable || !service.company.company_setting.online_payment_capable || bundle.present?
                  bookings.last[:has_discount] = false
                  bookings.last[:has_time_discount] = false
                  bookings.last[:discount] = 0
                  bookings.last[:time_discount] = 0
                  bookings.last[:has_treatment_discount] = false
                  bookings.last[:treatment_discount_discount] = 0
                elsif !service.company.company_setting.promo_offerer_capable
                  bookings.last[:has_time_discount] = false
                  bookings.last[:time_discount] = 0
                  bookings.last[:has_treatment_discount] = false
                  bookings.last[:treatment_discount_discount] = 0
                end

                if !service.has_sessions

                  bookings.last[:has_treatment_discount] = false
                  bookings.last[:treatment_discount] = 0

                  if service.has_time_discount && service.online_payable && service.company.company_setting.online_payment_capable && service.company.company_setting.promo_offerer_capable && service.time_promo_active

                    promo = Promo.where(:day_id => date.cwday, :service_promo_id => service.active_service_promo_id, :location_id => local.id).first

                    if !promo.nil?

                      service_promo = ServicePromo.find(service.active_service_promo_id)

                      #Check if there is a limit for bookings, and if there are any left
                      if service_promo.max_bookings > 0 || !service_promo.limit_booking

                        #Check if the promo is still active, and if the booking ends before the limit date

                        if bookings.last[:end].to_datetime < service_promo.book_limit_date && DateTime.now < service_promo.finish_date

                          if !(service_promo.morning_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.morning_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

                            bookings.last[:time_discount] = promo.morning_discount

                          elsif !(service_promo.afternoon_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.afternoon_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

                            bookings.last[:time_discount] = promo.afternoon_discount

                          elsif !(service_promo.night_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.night_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

                            bookings.last[:time_discount] = promo.night_discount

                          else

                            bookings.last[:time_discount] = 0

                          end
                        else
                          bookings.last[:time_discount] = 0
                        end
                      else
                        bookings.last[:time_discount] = 0
                      end

                    else

                      bookings.last[:time_discount] = 0

                    end

                  else

                    bookings.last[:has_time_discount] = false
                    bookings.last[:time_discount] = 0

                  end
                else

                  bookings.last[:has_time_discount] = false
                  bookings.last[:time_discount] = 0

                  #Check treatment promo
                  if service.has_treatment_promo && service.online_payable && service.company.company_setting.online_payment_capable && service.company.company_setting.promo_offerer_capable && service.time_promo_active

                    if !service.active_treatment_promo.nil?
                      if TreatmentPromoLocation.where(treatment_promo_id: service.active_treatment_promo_id, location_id: local.id).count > 0

                        if service.active_treatment_promo.max_bookings > 0

                          if !service.active_treatment_promo.limit_booking || (service.active_treatment_promo.finish_date > bookings.last[:start])
                            bookings.last[:has_treatment_discount] = true
                            bookings.last[:treatment_discount] = service.active_treatment_promo.discount
                          else
                            bookings.last[:has_treatment_discount] = false
                            bookings.last[:treatment_discount] = 0
                          end

                        else
                          bookings.last[:has_treatment_discount] = false
                          bookings.last[:treatment_discount] = 0
                        end

                      else
                        bookings.last[:has_treatment_discount] = false
                        bookings.last[:treatment_discount] = 0
                      end
                    else
                      bookings.last[:has_treatment_discount] = false
                      bookings.last[:treatment_discount] = 0
                    end

                  else
                    bookings.last[:has_treatment_discount] = false
                    bookings.last[:treatment_discount] = 0
                  end

                end

                #Check for active promos (regular or treatment)

                if service.active_service_promo_id.nil?
                  bookings.last[:service_promo_id] = "0"
                else
                  bookings.last[:service_promo_id] = service.active_service_promo_id
                end

                if service.active_treatment_promo_id.nil?
                  bookings.last[:treatment_promo_id] = "0"
                else
                  bookings.last[:treatment_promo_id] = service.active_treatment_promo_id
                end

                serviceStaffPos += 1

                if first_service.company.company_setting.allows_optimization
                  if dateTimePointer < provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
                    dateTimePointer = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
                  else
                    dateTimePointer += service.duration.minutes
                  end
                else
                  dateTimePointer = dateTimePointer + service.duration.minutes
                end

                if serviceStaffPos == serviceStaff.count
                  last_check = true

                  #Sum to gap_hours the gap_amount and reset gap flag.
                  if is_gap_hour
                    day_positive_gaps[day-1] += (total_services_duration - current_gap)
                    is_gap_hour = false
                    current_gap = 0
                  end
                end

                break

              end
            end
          end

          if !service_valid


            #Reset gap_hour
            is_gap_hour = false

            #First, check if there's a gap. If so, back dateTimePointer to (blocking_start - total_duration)
            #This way, you can give two options when there are gaps.

            #Assume there is no gap
            time_gap = 0

            if first_service.company.company_setting.allows_optimization && last_check

              if first_providers.count > 1

                first_providers.each do |first_provider|

                  book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

                  break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

                  provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

                  if !provider_time_gap.nil?

                    provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

                    if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
                      gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
                      if gap_diff > time_gap
                        time_gap = gap_diff
                      end
                    end

                  end

                  if book_gaps.count > 0
                    gap_diff = (book_gaps.first.start - dateTimePointer)/60
                    if gap_diff != 0
                      if gap_diff > time_gap
                        time_gap = gap_diff
                      end
                    end
                  end

                  if break_gaps.count > 0
                    gap_diff = (break_gaps.first.start - dateTimePointer)/60
                    if gap_diff != 0
                      if gap_diff > time_gap
                        time_gap = gap_diff
                      end
                    end
                  end

                end

              else

                #Get nearest blocking start and check the gap.
                #Blocking can come from provider time day end.

                first_provider = first_providers.first

                book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

                break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

                provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

                if !provider_time_gap.nil?

                  provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

                  if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
                    gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
                    if gap_diff > time_gap
                      time_gap = gap_diff
                    end
                  end

                end

                if book_gaps.count > 0
                  gap_diff = (book_gaps.first.start - dateTimePointer)/60
                  if gap_diff != 0
                    if gap_diff > time_gap
                      time_gap = gap_diff
                    end
                  end
                end

                if break_gaps.count > 0
                  gap_diff = (break_gaps.first.start - dateTimePointer)/60
                  if gap_diff != 0
                    if gap_diff > time_gap
                      time_gap = gap_diff
                    end
                  end
                end

              end

            end

            #logger.debug "DTP for gap: " + dateTimePointer.to_s
            #logger.debug "GAP: " + time_gap.to_s

            #Check for providers' bookings and breaks that include current dateTimePointer
            #If any, jump to the nearest end
            #Else, it's gotta be a resource issue or dtp is outside providers' time, so just add service duration as always
            #Last part could be optimized to jump to the nearest open provider's time

            #Time check must be an overlap of (dtp - dtp+service_duration) with booking/break (start - end)

            smallest_diff = first_service.duration
            #logger.debug "Defined smallest_diff: " + smallest_diff.to_s


            #Only do this when there is no gap
            if first_service.company.company_setting.allows_optimization && time_gap == 0

              if first_providers.count > 1

                first_providers.each do |first_provider|


                  book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')

                  if book_blockings.count > 0

                    book_diff = (book_blockings.first.end - dateTimePointer)/60
                    if book_diff < smallest_diff
                      smallest_diff = book_diff
                    end
                  else
                    break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')

                    if break_blockings.count > 0
                      break_diff = (break_blockings.first.end - dateTimePointer)/60
                      if break_diff < smallest_diff
                        smallest_diff = break_diff
                      end
                    end
                  end

                end

              else

                first_provider = first_providers.first

                book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')

                if book_blockings.count > 0
                  book_diff = (book_blockings.first.end - dateTimePointer)/60
                  if book_diff < smallest_diff
                    smallest_diff = book_diff
                  end
                else
                  break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')

                  if break_blockings.count > 0
                    break_diff = (break_blockings.first.end - dateTimePointer)/60
                    if break_diff < smallest_diff
                      smallest_diff = break_diff
                    end
                  end
                end

              end

              if smallest_diff == 0
                smallest_diff = first_service.duration
              end

            else

              smallest_diff = first_service.company.company_setting.calendar_duration

            end

            if first_service.company.company_setting.allows_optimization && time_gap > 0
              dateTimePointer = (dateTimePointer + time_gap.minutes) - total_services_duration.minutes
              is_gap_hour = true
              current_gap = time_gap
            else
              current_gap = 0
              dateTimePointer += smallest_diff.minutes
            end

            serviceStaffPos = 0
            bookings = []

            last_check = false

          end
        end

        if bookings.length == serviceStaff.length and (dateTimePointer <=> now + company_setting.after_booking.month) == -1

          has_time_discount = false
          has_treatment_discount = false
          bookings_group_discount = 0
          bookings_group_total_price = 0
          bookings_group_computed_price = 0

          if bookings.first[:has_sessions]
            if (bookings.first[:has_treatment_discount] && bookings.first[:treatment_discount] > 0) || (bookings.first[:has_discount] && bookings.first[:discount] > 0)
              has_treatment_discount = true
              if bookings.first[:has_treatment_discount] && !bookings.first[:has_discount]
                bookings_group_discount = bookings.first[:treatment_discount]
              elsif !bookings.first[:has_treatment_discount] && bookings.first[:has_discount]
                bookings_group_discount = bookings.first[:discount]
              else
                if bookings.first[:treatment_discount] > bookings.first[:discount]
                  bookings_group_discount = bookings.first[:treatment_discount]
                else
                  bookings_group_discount = bookings.first[:discount]
                end
              end
            else
              bookings_group_discount = 0
            end
            bookings_group_total_price = bookings.first[:price]
            bookings_group_computed_price = bookings_group_total_price.to_f*(100.0 - bookings_group_discount.to_f)/100.0
          else
            bookings.each do |b|
              bookings_group_total_price = bookings_group_total_price + b[:price]
              if (b[:has_time_discount] && b[:time_discount] > 0) || (b[:has_discount] && b[:discount] > 0)
                has_time_discount = true
                if b[:has_discount] && !b[:has_time_discount]
                  bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
                elsif !b[:has_discount] && b[:has_time_discount]
                  bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
                else
                  if b[:discount] > b[:time_discount]
                    bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
                  else
                    bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
                  end
                end
              else
                bookings_group_computed_price = bookings_group_computed_price + b[:price]
              end
            end
          end

          if (bookings_group_total_price != 0)
            bookings_group_discount = (100 - (bookings_group_computed_price/bookings_group_total_price)*100).round(1)
          end

          status = "hora-disponible"

          if has_time_discount || has_treatment_discount
            if session_booking.nil?
              status = "hora-promocion"
            end
          end

          #logger.debug "Time diff: "
          #logger.debug bookings[bookings.length-1][:end].to_s
          #logger.debug bookings[0][:start].to_s
          #logger.debug ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f.to_s
          hour_time_diff = ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f

          if hour_time_diff > max_time_diff
            max_time_diff = hour_time_diff
          end

          curr_promo_discount = 0

          if bookings.length == 1
            if has_time_discount
              curr_promo_discount = bookings[0][:time_discount]
            elsif has_treatment_discount
              curr_promo_discount = bookings[0][:treatment_discount]
            end
          end

          if params[:mandatory_discount]

            if has_time_discount || has_treatment_discount

              new_hour = {
                index: book_index,
                date: I18n.l(bookings[0][:start].to_date, format: :day_short),
                full_date: I18n.l(bookings[0][:start].to_date, format: :day),
                hour: I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs',
                bookings: bookings,
                status: status,
                start_block: bookings[0][:start].strftime("%H:%M"),
                end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
                available_provider: bookings[0][:provider_name],
                provider_id: bookings[0][:provider_id],
                promo_discount: curr_promo_discount.to_s,
                has_time_discount: has_time_discount,
                has_treatment_discount: has_treatment_discount,
                time_diff: hour_time_diff,
                has_sessions: bookings[0][:has_sessions],
                sessions_amount: bookings[0][:sessions_amount],
                group_discount: bookings_group_discount.to_s
              }

              book_index = book_index + 1
              book_summaries << new_hour

              if !hours_array.include?(new_hour)

                hours_array << new_hour
                total_hours_array << new_hour

              end

            end

          else

            new_hour = {
              index: book_index,
              date: I18n.l(bookings[0][:start].to_date, format: :day_short),
              full_date: I18n.l(bookings[0][:start].to_date, format: :day),
              hour: I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs',
              bookings: bookings,
              status: status,
              start_block: bookings[0][:start].strftime("%H:%M"),
              end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
              available_provider: bookings[0][:provider_name],
              provider_id: bookings[0][:provider_id],
              promo_discount: curr_promo_discount.to_s,
              has_time_discount: has_time_discount,
              has_treatment_discount: has_treatment_discount,
              has_sessions: bookings[0][:has_sessions],
              sessions_amount: bookings[0][:sessions_amount],
              time_diff: hour_time_diff,
              group_discount: bookings_group_discount.to_s
            }

            book_index = book_index + 1
            book_summaries << new_hour

            should_add = true

            #Legacy check
            # if !session_booking.nil?

            #   if !session_booking.service_promo_id.nil? && session_booking.max_discount != 0
            #     if new_hour[:group_discount].to_f < session_booking.max_discount.to_f
            #       should_add = false
            #     end
            #   end

            # end

            # if params[:edit] && status == 'hora-promocion'
            #   should_add = false
            # end

            if should_add
              if !hours_array.include?(new_hour)

                hours_array << new_hour
                total_hours_array << new_hour

              end
            end

          end

        end

      end

      @days_count += 1
      @week_blocks << { available_time: hours_array, formatted_date: date.strftime('%Y-%m-%d') }
      @days_row << { day_name: week_days[date.wday], day_number: date.strftime("%e")}

    end

      #loop_times = loop_times + 1

      #if loop_times > 16
      #  break
      #end

    #end

    week_blocks = ''
    days_row = ''

    time_column_width = 0.0

    width = ( (100.0 - time_column_width) / @days_count ).round(2).to_s

    #logger.debug "Week blocks " + @week_blocks.length.to_s
    #Get max time distance to construct the calendar

    min_open = 0
    max_close = 0

    local.location_times.each do |lt|
      if min_open == 0
        min_open = lt.open
      else
        if lt.open.strftime("%H:%M") < min_open.strftime("%H:%M")
          min_open = lt.open
        end
      end
    end

    local.location_times.each do |lt|
      if max_close == 0
        max_close = lt.close
      else
        if lt.close.strftime("%H:%M") > max_close.strftime("%H:%M")
          max_close = lt.close
        end
      end
    end

    min_block = 0
    min_block_str = ""

    #logger.debug "THA: " + total_hours_array.count.to_s

    total_hours_array.each do |hour|
      if min_block == 0
        min_block = hour[:bookings][0][:start]
      else
        if hour[:start_block] < min_block.strftime("%H:%M")
          min_block = hour[:bookings][0][:start]
        end
      end
    end

    #logger.debug "Min block: " + min_block.to_s
    #logger.debug "Max close: " + max_close.to_s

    if min_block != 0

      min_block_str = min_block.strftime("%H:%M")
      min_block = (min_block.hour * 60 + min_block.min) * 60
      max_close = (max_close.hour * 60 + max_close.min) * 60

      hours_diff = (max_close - min_block)/60

    else

      min_block = (min_open.hour * 60 + min_open.min) * 60
      max_close = (max_close.hour * 60 + max_close.min) * 60
      hours_diff = (max_close - min_block)/60

    end

    #logger.debug "Hours diff: "
    #logger.debug "Max close: " + max_close.to_s
    #logger.debug "Min open:" + min_open.to_s
    #logger.debug "Min block: " + min_block.to_s
    #logger.debug "Hours diff:" + hours_diff.to_s

    time_prop = 0

    if max_time_diff != 0
      time_prop = hours_diff/max_time_diff
    end

    #logger.debug "Max gaps: " + day_positive_gaps.max.to_s
    calendar_height = time_prop*67
    adjusted_calendar_height = calendar_height + calendar_height*day_positive_gaps.max.to_f/hours_diff
    #(day_positive_gaps.max.to_f * 100 / (60 * 100))*67

    #logger.debug calendar_height.to_s + " *** " + adjusted_calendar_height.to_s
    #adjusted_calendar_height = adjusted_calendar_height * 1.0207



    #logger.debug "Time prop: " + time_prop.to_s


    if time_prop != 0

      @week_blocks.each do |week_block|
        week_blocks += '<div class="columna-dia" data-date="' + week_block[:formatted_date] + '" style="width: ' + width + '%; height: ' + adjusted_calendar_height.round(2).to_s + 'px !important;">'

        previous_hour = min_open.strftime("%H:%M")
        if min_block != 0
          previous_hour = min_block_str
        end

        week_block[:available_time].each do |hour|

          if hours_diff != 0

            hour_diff = (calendar_height*hour[:time_diff]/hours_diff).round(2)
            span_diff = hour_diff - 8
            top_margin = (calendar_height * (hour[:start_block].to_time - previous_hour.to_time)/(60 * hours_diff) ).round(2)
          else

            new_min_open = 0
            new_max_close = 0

            local.location_times.each do |lt|
              if new_min_open == 0
                new_min_open = lt.open
              else
                if lt.open.strftime("%H:%M") < new_min_open.strftime("%H:%M")
                  new_min_open = lt.open
                end
              end
            end

            local.location_times.each do |lt|
              if new_max_close == 0
                new_max_close = lt.close
              else
                if lt.close.strftime("%H:%M") > new_max_close.strftime("%H:%M")
                  new_max_close = lt.open
                end
              end
            end

            new_min_block = (new_min_open.hour * 60 + new_min_open.min) * 60
            new_max_close = (new_max_close.hour * 60 + new_max_close.min) * 60

            hours_diff = (new_max_close - new_min_block)/60

            hour_diff = (calendar_height*hour[:time_diff]/hours_diff).round(2)
            span_diff = hour_diff - 8
            top_margin = (calendar_height * (hour[:start_block].to_time - previous_hour.to_time)/(60 * hours_diff) ).round(2)
          end


          if hour[:status] != "hora-promocion"

            #

            if top_margin > 0
              week_blocks += '<div style="border-top: 1px solid #d2d2d2 !important; margin-top: ' + top_margin.to_s + 'px !important; height: ' + hour_diff.to_s + 'px;" class="bloque-hora ' + hour[:status] + '" data-start="' + hour[:start_block] + '" data-end="' + hour[:end_block] + '" data-providerid="' + hour[:provider_id].to_s + '" data-provider="' + hour[:available_provider] + '" data-discount="' + hour[:promo_discount] + '" data-index="' + hour[:index].to_s + '" data-timediscount="' + hour[:has_time_discount].to_s + '" data-groupdiscount="' + hour[:group_discount] + '"><span style="line-height: ' + hour_diff.to_s + 'px; height: ' + span_diff.to_s + 'px;">' + hour[:start_block] + ' - ' + hour[:end_block] + '</span></div>'
            else
              week_blocks += '<div style="height: ' + hour_diff.to_s + 'px;" class="bloque-hora ' + hour[:status] + '" data-start="' + hour[:start_block] + '" data-end="' + hour[:end_block] + '" data-providerid="' + hour[:provider_id].to_s + '" data-provider="' + hour[:available_provider] + '" data-discount="' + hour[:promo_discount] + '" data-index="' + hour[:index].to_s + '" data-timediscount="' + hour[:has_time_discount].to_s + '" data-groupdiscount="' + hour[:group_discount] + '"><span style="line-height: ' + hour_diff.to_s + 'px; height: ' + span_diff.to_s + 'px;">' + hour[:start_block] + ' - ' + hour[:end_block] + '</span></div>'
            end

          else

            if @week_blocks.count > 5
              if top_margin > 0
                week_blocks += '<div style="border-top: 1px solid #d2d2d2 !important; margin-top: ' + top_margin.to_s + 'px !important; height: ' + hour_diff.to_s + 'px;" class="bloque-hora ' + hour[:status] + '" data-start="' + hour[:start_block] + '" data-end="' + hour[:end_block] + '" data-providerid="' + hour[:provider_id].to_s + '" data-provider="' + hour[:available_provider] + '" data-discount="' + hour[:promo_discount] + '" data-index="' +  hour[:index].to_s + '" data-timediscount="' + hour[:has_time_discount].to_s + '" data-groupdiscount="' + hour[:group_discount] + '"><span style="line-height: ' + hour_diff.to_s + 'px; height: ' + span_diff.to_s + 'px;">' + '<div class="in-block-discount">' + ActionController::Base.helpers.image_tag('promociones/icono_promociones.png', class: 'promotion-hour-icon-green', size: "18x18") + ActionController::Base.helpers.image_tag('promociones/icono_promociones_blanco.png', class: 'promotion-hour-icon-white', size: "18x18") + '&nbsp;-' + hour[:group_discount] + '%</div>&nbsp;' + hour[:start_block] + '</span></div>'
              else
                week_blocks += '<div style="height: ' + hour_diff.to_s + 'px;" class="bloque-hora ' + hour[:status] + '" data-start="' + hour[:start_block] + '" data-end="' + hour[:end_block] + '" data-providerid="' + hour[:provider_id].to_s + '" data-provider="' + hour[:available_provider] + '" data-discount="' + hour[:promo_discount] + '" data-index="' +  hour[:index].to_s + '" data-timediscount="' + hour[:has_time_discount].to_s + '" data-groupdiscount="' + hour[:group_discount] + '"><span style="line-height: ' + hour_diff.to_s + 'px; height: ' + span_diff.to_s + 'px;">' + '<div class="in-block-discount">' + ActionController::Base.helpers.image_tag('promociones/icono_promociones.png', class: 'promotion-hour-icon-green', size: "18x18") + ActionController::Base.helpers.image_tag('promociones/icono_promociones_blanco.png', class: 'promotion-hour-icon-white', size: "18x18") + '&nbsp;-' + hour[:group_discount] + '%</div>&nbsp;' + hour[:start_block] + '</span></span></div>'
              end
            else
              if top_margin > 0
                week_blocks += '<div style="border-top: 1px solid #d2d2d2 !important; margin-top: ' + top_margin.to_s + 'px !important; height: ' + hour_diff.to_s + 'px;" class="bloque-hora ' + hour[:status] + '" data-start="' + hour[:start_block] + '" data-end="' + hour[:end_block] + '" data-providerid="' + hour[:provider_id].to_s + '" data-provider="' + hour[:available_provider] + '" data-discount="' + hour[:promo_discount] + '" data-index="' +  hour[:index].to_s + '" data-timediscount="' + hour[:has_time_discount].to_s + '" data-groupdiscount="' + hour[:group_discount] + '"><span style="line-height: ' + hour_diff.to_s + 'px; height: ' + span_diff.to_s + 'px; font-size: 14px;">' + '<div class="in-block-discount">' + ActionController::Base.helpers.image_tag('promociones/icono_promociones.png', class: 'promotion-hour-icon-green', size: "18x18") + ActionController::Base.helpers.image_tag('promociones/icono_promociones_blanco.png', class: 'promotion-hour-icon-white', size: "18x18") + '&nbsp;-' + hour[:group_discount] + '%</div> &nbsp;' + hour[:start_block] + ' - ' + hour[:end_block]  + '</span></div>'
              else
                week_blocks += '<div style="height: ' + hour_diff.to_s + 'px;" class="bloque-hora ' + hour[:status] + '" data-start="' + hour[:start_block] + '" data-end="' + hour[:end_block] + '" data-providerid="' + hour[:provider_id].to_s + '" data-provider="' + hour[:available_provider] + '" data-discount="' + hour[:promo_discount] + '" data-index="' +  hour[:index].to_s + '" data-timediscount="' + hour[:has_time_discount].to_s + '" data-groupdiscount="' + hour[:group_discount] + '"><span style="line-height: ' + hour_diff.to_s + 'px; height: ' + span_diff.to_s + 'px; font-size: 14px;">' + '<div class="in-block-discount">' + ActionController::Base.helpers.image_tag('promociones/icono_promociones.png', class: 'promotion-hour-icon-green', size: "18x18") + ActionController::Base.helpers.image_tag('promociones/icono_promociones_blanco.png', class: 'promotion-hour-icon-white', size: "18x18") + '&nbsp;-' + hour[:group_discount] + '%</div> &nbsp;' + hour[:start_block] + ' - ' + hour[:end_block]  + '</span></span></div>'
              end
            end
          end

          previous_hour = hour[:end_block]

        end
        if week_block[:available_time].count < 1
          week_blocks += '&nbsp;<div class="clear">&nbsp;</div></div>'
        else
          week_blocks += '<div class="clear"></div></div>'
        end
      end

    end
    week_blocks += '<div class="clear"></div>'

    @days_row.each do |day|
      days_row += '<div class="dia-semana" style="width: ' + width + '%;">' + day[:day_name] + ' ' + day[:day_number] + '</div>'
    end

    days_count = @days_count

    render  :json => { panel_body: week_blocks, days_row: days_row, days_count: days_count, book_summaries: book_summaries, current_date: current_date}
    #

  end


  def optimizer_hours

    week_days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
    require 'date'

    @hours_array = []

    # Generals
    array_length = if params[:resultsLength] then params[:resultsLength].to_i else 6 end

    local = Location.find(params[:local])
    company_setting = local.company.company_setting
    cancelled_id = Status.find_by(name: 'Cancelado').id
    serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)

    if params[:start_date] and params[:start_date] != ""
      if params[:start_date].to_datetime > now
        now = params[:start_date].to_datetime
      end
    end

    days_ids = [1,2,3,4,5,6,7]
    index = days_ids.find_index(now.cwday)
    ordered_days = days_ids[index, days_ids.length] + days_ids[0, index]

    day_positive_gaps = [0,0,0,0,0,0,0]

    @days_count = 0
    @week_blocks = []
    @days_row = []

    book_index = 0
    book_summaries = []

    total_hours_array = []

    loop_times = 0

    max_time_diff = 0

    #Save first service and it's providers for later use

    first_service = Service.find(serviceStaff[0][:service])
    first_providers = []
    if serviceStaff[0][:provider] != "0"
      first_providers << ServiceProvider.find(serviceStaff[0][:provider])
    else
      first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(:order, :public_name)
    end

    #Look for services and providers and save them for later use.
    #Also, save total services duration

    total_services_duration = 0

    #False if last tried block allocation failed.
    #Used for searching gaps. They should be looked for only if last block culd be allocated,
    #because if not, then there isn't anyway that coming back in time cause correct allocation.
    last_check = false

    #Checks if the block being allocated is from a gap
    is_gap_hour = false

    #Holds current_gap to sum a day's total gap and adjust calendar's height
    current_gap = 0

    services_arr = []
    providers_arr = []
    for i in 0..serviceStaff.length-1
      services_arr[i] = Service.find(serviceStaff[i][:service])
      total_services_duration += services_arr[i].duration
      if serviceStaff[i][:provider] != "0"
        providers_arr[i] = []
        providers_arr[i] << ServiceProvider.find(serviceStaff[i][:provider])
      else
        providers_arr[i] = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true)
      end
    end

    #providers_arr = []
    #for i

    after_date = DateTime.now + company_setting.after_booking.months

    dtp = nil

      while dtp.nil?
        day = now.cwday
        dtp = local.location_times.where(day_id: day).order(:open).first
        day = day+1
        if day > 7
          day = 1
        end
      end

      day = day-1
      if day < 1
        day = 7
      end

      dateTimePointer = dtp.open

      dateTimePointer = DateTime.new(now.year, now.mon, now.mday, dateTimePointer.hour, dateTimePointer.min)
      day_open_time = dateTimePointer

      dateTimePointerEnd = dateTimePointer

      now = dateTimePointer
      date = now

      hours_array = []

      day_close = local.location_times.where(day_id: day).order(:close).first.close
      limit_date = DateTime.new(dateTimePointer.year, dateTimePointer.mon, dateTimePointer.mday, day_close.hour, day_close.min)

      while @hours_array.length < array_length

        #logger.debug "DTP: " + dateTimePointer.to_s

        serviceStaffPos = 0
        bookings = []

        while serviceStaffPos < serviceStaff.length



          if dateTimePointer >= limit_date
            day = day + 1
            if day > 7
              day = 1
            end

            dtp = nil

            while dtp.nil?
              logger.debug "Day: " + day.to_s
              dtp = local.location_times.where(day_id: day).order(:open).first
              if dtp.nil?
                logger.debug "NIL"
              else
                logger.debug "GOOD"
              end
              day = day+1
              if day > 7
                day = 1
              end

            end

            day = day-1
            if day < 1
              day = 7
            end

            day_close = local.location_times.where(day_id: day).order(:close).first.close
            new_limit = limit_date + 1.days
            limit_date = DateTime.new(new_limit.year, new_limit.mon, new_limit.mday, day_close.hour, day_close.min)

            dateTimePointer = dtp.open

            dateTimePointer = DateTime.new(limit_date.year, limit_date.mon, limit_date.mday, dateTimePointer.hour, dateTimePointer.min)
            day_open_time = dateTimePointer

            dateTimePointerEnd = dateTimePointer

            now = dateTimePointer

            date = now

          end

          service_valid = false
          service = services_arr[serviceStaffPos]

          logger.debug "Service: " + service.name
          logger.debug "DTP: " + dateTimePointer.to_s


          #Get providers min
          min_pt = ProviderTime.where(:service_provider_id => ServiceProvider.where(active: true, online_booking: true, :location_id => local.id, :id => ServiceStaff.where(:service_id => service.id).pluck(:service_provider_id)).pluck(:id)).where(day_id: day).order(:open).first

          if !min_pt.nil? && min_pt.open.strftime("%H:%M") > dateTimePointer.strftime("%H:%M")
            dateTimePointer = min_pt.open
            dateTimePointer = DateTime.new(now.year, now.mon, now.mday, dateTimePointer.hour, dateTimePointer.min)
            day_open_time = dateTimePointer
          end

          logger.debug "Debug 1"

          #To deattach continous services, just delete the serviceStaffPos condition

          if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization && last_check
            dateTimePointer = dateTimePointer - total_services_duration.minutes + first_service.company.company_setting.calendar_duration.minutes
          end

          if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization
            #Calculate offset
            offset_diff = (dateTimePointer-day_open_time)*24*60
            offset_rem = offset_diff % first_service.company.company_setting.calendar_duration
            if offset_rem != 0
              dateTimePointer = dateTimePointer + (first_service.company.company_setting.calendar_duration - offset_rem).minutes
            end
          end

          logger.debug "Debug 2"

          #Find next service block starting from dateTimePointer
          service_sum = service.duration.minutes

          minHour = now
          #logger.debug "min_hours: " + minHour.to_s
          if !params[:admin] && minHour <= DateTime.now
            minHour += company_setting.before_booking.hours
          end
          if dateTimePointer >= minHour
            service_valid = true
          end

          logger.debug "Debug 3"

          # Hora dentro del horario del local

          if service_valid
            service_valid = false
            local.location_times.where(day_id: dateTimePointer.cwday).each do |times|
              location_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.open.hour, times.open.min)
              location_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.close.hour, times.close.min)

              logger.debug "Debug 4"

              if location_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= location_close
                service_valid = true
                break
              end
            end
          end

          logger.debug "Debug 5"

          # Horario dentro del horario del provider
          if service_valid
            providers = []
            if serviceStaff[serviceStaffPos][:provider] != "0"
              providers << ServiceProvider.find(serviceStaff[serviceStaffPos][:provider])
              #providers = providers_arr[serviceStaffPos]
              logger.debug "Debug 6"
            else

              #Check if providers have same day open
              #If they do, choose the one with less ocupations to start with
              #If they don't, choose the one that starts earlier.
              if service.check_providers_day_times(dateTimePointer)
                providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }

                #providers = providers_arr[serviceStaffPos].order(:order, :public_name).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }

              else
                providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(order: :asc).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }

                #providers = providers_arr[serviceStaffPos].order(:order, :public_name).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }
              end

              logger.debug "Debug 7"

            end

            logger.debug "Debug 8"

            providers.each do |provider|

              provider_min_pt = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first
              if !provider_min_pt.nil? && dateTimePointer.strftime("%H:%M") < provider_min_pt.open.strftime("%H:%M")
                dateTimePointer = provider_min_pt.open
                dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
                #dateTimePointer = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open.to_datetime
              end

              logger.debug "Debug 9"

              service_valid = false

              #Check directly on query instead of looping through

              provider.provider_times.where(day_id: dateTimePointer.cwday).each do |provider_time|
                provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
                provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

                if provider_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= provider_close
                  service_valid = true
                  break
                end
              end

              logger.debug "Debug 10"

              # #Stored procedure for time check

              # proc_start_date = dateTimePointer.to_s.gsub('T', ' ')
              # proc_end_date = dateTimePointer + service.duration.minutes
              # proc_end_date = proc_end_date.to_s.gsub('T', ' ')

              # if ActiveRecord::Base.connection.execute("select check_hour(#{local.id}, #{provider.id}, #{service.id}, '#{proc_start_date}', '#{proc_end_date}')")[0]['check_hour'] == 't'
              #   service_valid = true
              # else
              #   service_valid = false
              # end

              # Provider breaks
              if service_valid

                if provider.provider_breaks.where.not('(provider_breaks.end <= ? or ? <= provider_breaks.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
                  service_valid = false
                end

              end

              logger.debug "Debug 11"

              # Cross Booking
              if service_valid

                if !service.group_service
                  if Booking.where(service_provider_id: provider.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
                    service_valid = false
                  end
                else
                  if Booking.where(service_provider_id: provider.id, service_id: service.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count >= service.capacity
                    service_valid = false
                  end
                end

              end

              logger.debug "Debug 12"

              # Recursos
              if service_valid and service.resources.count > 0
                service.resources.each do |resource|
                  if !local.resource_locations.pluck(:resource_id).include?(resource.id)
                    service_valid = false
                    break
                  end
                  used_resource = 0
                  group_services = []
                  pointerEnd = dateTimePointer+service.duration.minutes
                  local.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
                    if location_booking.status_id != cancelled_id && !(pointerEnd <= location_booking.start.to_datetime || location_booking.end.to_datetime <= dateTimePointer)
                      if location_booking.service.resources.include?(resource)
                        if !location_booking.service.group_service
                          used_resource += 1
                        else
                          if location_booking.service != service || location_booking.service_provider != provider
                            group_services.push(location_booking.service_provider.id)
                          end
                        end
                      end
                    end
                  end
                  if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: local.id).first.quantity
                    service_valid = false
                    break
                  end
                end
              end

              logger.debug "Debug 13"

              if service_valid

                book_sessions_amount = 0
                if service.has_sessions
                  book_sessions_amount = service.sessions_amount
                end

                bookings << {
                  :service => service.id,
                  :provider => provider.id,
                  :start => dateTimePointer,
                  :end => dateTimePointer + service.duration.minutes,
                  :service_name => service.name,
                  :provider_name => provider.public_name,
                  :provider_lock => serviceStaff[serviceStaffPos][:provider] != "0",
                  :price => service.price,
                  :online_payable => service.online_payable,
                  :has_discount => service.has_discount,
                  :discount => service.discount,
                  :show_price => service.show_price
                }

                serviceStaffPos += 1

                if first_service.company.company_setting.allows_optimization
                  if dateTimePointer < provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
                    dateTimePointer = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
                  else
                    dateTimePointer += service.duration.minutes
                  end
                else
                  dateTimePointer = dateTimePointer + service.duration.minutes
                end

                logger.debug "Debug 14"

                if serviceStaffPos == serviceStaff.count
                  last_check = true

                  #Sum to gap_hours the gap_amount and reset gap flag.
                  if is_gap_hour
                    day_positive_gaps[day-1] += (total_services_duration - current_gap)
                    is_gap_hour = false
                    current_gap = 0
                  end
                end

                logger.debug "Debug 15"

                break

              end
            end
          end

          logger.debug "Debug 16"

          if !service_valid


            #Reset gap_hour
            is_gap_hour = false

            #First, check if there's a gap. If so, back dateTimePointer to (blocking_start - total_duration)
            #This way, you can give two options when there are gaps.

            logger.debug "DTP starting not valid: " + dateTimePointer.to_s
            logger.debug "Last Check: " + last_check.to_s

            #Assume there is no gap
            time_gap = 0

            if first_service.company.company_setting.allows_optimization && last_check

              if first_providers.count > 1

                first_providers.each do |first_provider|

                  book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

                  break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

                  provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

                  if !provider_time_gap.nil?

                    provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

                    if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
                      gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
                      #logger.debug "Enters provider_close and gap is " + gap_diff.to_s
                      #logger.debug "Provider close: " + provider_close.to_s
                      if gap_diff > time_gap
                        time_gap = gap_diff
                      end
                    end

                  end

                  if book_gaps.count > 0
                    gap_diff = (book_gaps.first.start - dateTimePointer)/60
                    #logger.debug "Enters bookings and gap is " + gap_diff.to_s
                    #logger.debug "Book start: " + book_gaps.first.start.to_s
                    if gap_diff != 0
                      if gap_diff > time_gap
                        time_gap = gap_diff
                      end
                    end
                  end

                  if break_gaps.count > 0
                    gap_diff = (break_gaps.first.start - dateTimePointer)/60
                    #logger.debug "Enters breaks and gap is " + gap_diff.to_s
                    #logger.debug "Break start: " + break_gaps.first.start.to_s
                    if gap_diff != 0
                      if gap_diff > time_gap
                        time_gap = gap_diff
                      end
                    end
                  end

                end

                logger.debug "Debug 17"

              else

                #Get nearest blocking start and check the gap.
                #Blocking can come from provider time day end.

                first_provider = first_providers.first

                book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

                break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

                provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

                if !provider_time_gap.nil?

                  provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

                  if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
                    gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
                    #logger.debug "Enters provider_close and gap is " + gap_diff.to_s
                    #logger.debug "Provider close: " + provider_close.to_s
                    if gap_diff > time_gap
                      time_gap = gap_diff
                    end
                  end

                end

                if book_gaps.count > 0
                  gap_diff = (book_gaps.first.start - dateTimePointer)/60
                  #logger.debug "Enters bookings and gap is " + gap_diff.to_s
                  #logger.debug "Book start: " + book_gaps.first.start.to_s
                  if gap_diff != 0
                    if gap_diff > time_gap
                      time_gap = gap_diff
                    end
                  end
                end

                if break_gaps.count > 0
                  gap_diff = (break_gaps.first.start - dateTimePointer)/60
                  #logger.debug "Enters breaks and gap is " + gap_diff.to_s
                  #logger.debug "Break start: " + break_gaps.first.start.to_s
                  if gap_diff != 0
                    if gap_diff > time_gap
                      time_gap = gap_diff
                    end
                  end
                end

                logger.debug "Debug 18"

              end

            end

            #Check for providers' bookings and breaks that include current dateTimePointer
            #If any, jump to the nearest end
            #Else, it's gotta be a resource issue or dtp is outside providers' time, so just add service duration as always
            #Last part could be optimized to jump to the nearest open provider's time

            #Time check must be an overlap of (dtp - dtp+service_duration) with booking/break (start - end)

            smallest_diff = first_service.duration
            #logger.debug "Defined smallest_diff: " + smallest_diff.to_s


            #Only do this when there is no gap
            if first_service.company.company_setting.allows_optimization && time_gap == 0

              if first_providers.count > 1

                first_providers.each do |first_provider|

                  book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')
                  if book_blockings.count > 0

                    book_diff = (book_blockings.first.end - dateTimePointer)/60
                    if book_diff < smallest_diff
                      smallest_diff = book_diff
                    end
                  else
                    break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')
                    if break_blockings.count > 0
                      break_diff = (break_blockings.first.end - dateTimePointer)/60
                      if break_diff < smallest_diff
                        smallest_diff = break_diff
                      end
                    end
                  end

                end

              else

                first_provider = first_providers.first

                book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')
                if book_blockings.count > 0
                  book_diff = (book_blockings.first.end - dateTimePointer)/60
                  if book_diff < smallest_diff
                    smallest_diff = book_diff
                  end
                else
                  break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')
                  if break_blockings.count > 0
                    break_diff = (break_blockings.first.end - dateTimePointer)/60
                    if break_diff < smallest_diff
                      smallest_diff = break_diff
                    end
                  end
                end

              end

              if smallest_diff == 0
                smallest_diff = first_service.duration
              end

            else

              smallest_diff = first_service.company.company_setting.calendar_duration

            end

            if first_service.company.company_setting.allows_optimization && time_gap > 0
              dateTimePointer = (dateTimePointer + time_gap.minutes) - total_services_duration.minutes
              is_gap_hour = true
              current_gap = time_gap
            else
              current_gap = 0
              dateTimePointer += smallest_diff.minutes
            end

            logger.debug "Smalled diff: " + smallest_diff.to_s
            logger.debug "Gap DTP: " + dateTimePointer.to_s

            serviceStaffPos = 0
            bookings = []

            last_check = false

          end
        end

        logger.debug "Debug 20"

        if bookings.length == serviceStaff.length and (dateTimePointer <=> now + company_setting.after_booking.month) == -1
          @hours_array << {
            :date => I18n.l(bookings[0][:start].to_date, format: :day_short),
            :full_date => I18n.l(bookings[0][:start].to_date, format: :day),
            :hour => I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs',
            :bookings => bookings
          }
        end

      end



    respond_to do |format|
      format.html
      format.json { render :json => @hours_array }
    end

  end


  def optimizer_data
    @local = Location.find(params[:local])
    @company = @local.company

    @bookings = JSON.parse(params[:bookings], symbolize_names: true)
    @string_bookings = JSON.pretty_generate(@bookings)

    host = request.host_with_port
    @url = @local.get_web_address + '.' + host[host.index(request.domain)..host.length]

    # hash_array = Array.new

    # @bookings.each do |booking|

    #   book_array = {:start => booking.start, :end => booking.end, :provider => booking.service_provider_id, :service => booking.service_id, :provider_lock => booking.provider_lock, :max_changes => booking.max_changes}

    #   hash_array << book_array

    # end

    # json_array = JSON.generate(hash_array)


    @outcall = false
    @bookings.each do |booking|
      service = Service.find(booking[:service])
      @outcall ||= service.outcall
    end

    render layout: "workflow"
  end

  def get_treatment_price

    json_response = []
    errors = []

    if params[:service_id].blank?
      errors << "No se puede encontrar un servicio sin id."
      json_response << "error"
      json_response << errors
      render :json => json_response
      return
    end

    service = Service.find(params[:service_id])

    session_booking = nil
    if !params[:session_booking_id].blank? && params[:session_booking_id] != "0" && params[:session_booking_id] != 0
      session_booking = SessionBooking.find(params[:session_booking_id])
    end

    treatment_price = 0.0

    if session_booking.nil?
      treatment_price = service.price
    else
      session_booking.bookings.each do |booking|
        if booking.is_session_booked
          if !booking.price.nil?
            treatment_price += booking.price
          elsif !booking.list_price.nil?
            if !booking.discount.nil?
              booking.price = booking.list_price * (100 - booking.discount) / 100
              treatment_price += booking.price
              booking.save
            else
              booking.discount = 0
              booking.price = booking.list_price
              treatment_price += booking.price
              booking.save
            end
          else
            booking.list_price = service.price / session_booking.sessions_amount
            booking.price = service.price / session_booking.sessions_amount
            booking.discount = 0
            booking.save
            treatment_price += service.price / session_booking.sessions_amount
          end
        else
          treatment_price += service.price / session_booking.sessions_amount
        end
      end
    end

    json_response << "ok"
    json_response << treatment_price

    render :json => json_response

  end

  def booking_rating
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    ids = crypt.decrypt_and_verify(params[:encrypted_ids])
    @bookings_group = Booking.where(id: ids)
  end

  def get_treatment_info

    @session_booking = @booking.session_booking
    @json_response = {session_booking: @session_booking, bookings: @session_booking.bookings}

    render :json => @json_response

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
      if mobile_request?
        @company = current_user.company
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:start, :end, :notes, :service_provider_id, :service_id, :price, :user_id, :status_id, :promotion_id, :client_id, :client_first_name, :client_last_name, :client_email, :client_phone, :confirmation_code, :company_comment, :web_origin, :provider_lock, :send_mail, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_record, :client_second_phone, :client_gender, :staff_code, :deal_code, :session_booking_id, :payed_state, :bundled, :bundle_id, :bundled_delete)
    end

    def booking_buffer_params
      params.permit(bookings: [:start, :end, :notes, :service_provider_id, :service_id, :price, :user_id, :status_id, :promotion_id, :client_id, :client_first_name, :client_last_name, :client_email, :client_phone, :confirmation_code, :company_comment, :web_origin, :provider_lock, :send_mail, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_record, :client_second_phone, :client_gender, :staff_code, :session_booking_id, :payed_state, :bundled, :bundle_id])
    end
end
