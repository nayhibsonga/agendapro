class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:create, :force_create, :booking_valid, :provider_booking, :book_service, :book_error, :remove_bookings, :edit_booking, :edit_booking_post, :cancel_booking, :cancel_all_booking, :confirm_booking, :check_user_cross_bookings, :blocked_edit, :blocked_cancel, :optimizer_hours, :optimizer_data, :transfer_error_cancel]
  before_action :quick_add, except: [:create, :force_create, :booking_valid, :provider_booking, :book_service, :book_error, :remove_bookings, :edit_booking, :edit_booking_post, :cancel_booking, :confirm_booking, :check_user_cross_bookings, :blocked_edit, :blocked_cancel, :optimizer_hours, :optimizer_data, :transfer_error_cancel]
  layout "admin", except: [:book_service, :book_error, :remove_bookings, :provider_booking, :edit_booking, :edit_booking_post, :cancel_booking, :transfer_error_cancel, :confirm_booking, :check_user_cross_bookings, :blocked_edit, :blocked_cancel, :optimizer_hours, :optimizer_data]

  # GET /bookings
  # GET /bookings.json
  def index
    @company = Company.find(current_user.company_id)
    if current_user.role_id == Role.find_by_name("Staff").id || current_user.role_id == Role.find_by_name("Staff (sin edición)").id
      @locations = Location.where(:active => true, id: ServiceProvider.where(active: true, id: UserProvider.where(user_id: current_user.id).pluck(:service_provider_id)).pluck(:location_id)).accessible_by(current_ability).order(:order)
    else
      @locations = Location.where(:active => true).accessible_by(current_ability).order(:order)
    end
    @company_setting = @company.company_setting
    @service_providers = ServiceProvider.where(location_id: @locations).order(:order)
    @bookings = Booking.where(service_provider_id: @service_providers)
    @booking = Booking.new
    @provider_break = ProviderBreak.new
  end

  def fixed_index
    @company = Company.where(id: current_user.company_id)
    if current_user.role_id == Role.find_by_name("Staff").id || current_user.role_id == Role.find_by_name("Staff (sin edición)").id
      @locations = Location.where(:active => true, :id => ServiceProvider.where(active: true).pluck(:location_id)).accessible_by(current_ability).order(:order)
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
    is_payed = false
    if u.payed && !u.payed_booking.nil?
      is_payed = true
    end
    @booking_json = { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :price => u.price, :status_id => u.status_id, :client_id => u.client.id, :first_name => u.client.first_name, :last_name => u.client.last_name, :email => u.client.email, :phone => u.client.phone, :identification_number => u.client.identification_number, :send_mail => u.send_mail, :provider_lock => u.provider_lock, :notes => u.notes,  :company_comment => u.company_comment, :service_provider_active => u.service_provider.active, :service_active => u.service.active, :service_provider_name => u.service_provider.public_name, :service_name => u.service.name, :address => u.client.address, :district => u.client.district, :city => u.client.city, :birth_day => u.client.birth_day, :birth_month => u.client.birth_month, :birth_year => u.client.birth_year, :age => u.client.age, :gender => u.client.gender, deal_code: @booking.deal.nil? ? nil : @booking.deal.code, :payed => is_payed }
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

    booking_buffer_params[:bookings].each do |pos, buffer_params|
      staff_code = nil
      new_booking_params = buffer_params.except(:client_first_name, :client_last_name, :client_phone, :client_email, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_gender, :staff_code)
      @booking = Booking.new(new_booking_params)

      if @company_setting.staff_code
        if !buffer_params[:staff_code].blank? && StaffCode.where(company_id: current_user.company_id, code: buffer_params[:staff_code]).count > 0
          staff_code = StaffCode.where(company_id: current_user.company_id, code: buffer_params[:staff_code]).first.id
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
          @client.gender = buffer_params[:client_gender]
          @client.save
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
          @client.gender = buffer_params[:client_gender]
          @client.save
          if User.find_by_email(@client.email)
            new_booking_params[:user_id] = User.find_by_email(@client.email).id
          end
        else
          if !buffer_params[:client_email].nil?
            if buffer_params[:client_email].empty?
              if Client.where(email: '', company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => buffer_params[:client_first_name]+' '+buffer_params[:client_last_name]).count > 0
                client = Client.where(email: '', company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => buffer_params[:client_first_name]+' '+buffer_params[:client_last_name]).first
                @booking.client = client
              else
                client = Client.new(email: buffer_params[:client_email], first_name: buffer_params[:client_first_name], last_name: buffer_params[:client_last_name], phone: buffer_params[:client_phone], address: buffer_params[:client_address], district: buffer_params[:client_district], city: buffer_params[:client_city], birth_day: buffer_params[:client_birth_day], birth_month: buffer_params[:client_birth_month], birth_year: buffer_params[:client_birth_year], age: buffer_params[:client_age], gender: buffer_params[:client_gender], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id)
                if client.save
                  @booking.client = client
                end
              end
            else
              if Client.where(email: buffer_params[:client_email], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).count > 0
                client = Client.where(email: buffer_params[:client_email], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).first
                @booking.client = client
              else
                client = Client.new(email: buffer_params[:client_email], first_name: buffer_params[:client_first_name], last_name: buffer_params[:client_last_name], phone: buffer_params[:client_phone], address: buffer_params[:client_address], district: buffer_params[:client_district], city: buffer_params[:client_city], birth_day: buffer_params[:client_birth_day], birth_month: buffer_params[:client_birth_month], birth_year: buffer_params[:client_birth_year], age: buffer_params[:client_age], gender: buffer_params[:client_gender], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id)
                if client.save
                  @booking.client = client
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

      if @booking.save
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
          :prepayed => prepayed
        }

        BookingHistory.create(booking_id: @booking.id, action: "Creada por Calendario", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: current_user.id, staff_code_id: staff_code)
      else
        @errors << {
            :booking => pos,
            :errors => @booking.errors.full_messages
          }
      end
    end
    respond_to do |format|
      if @errors.length == 0
        if @bookings.length > 1
          Booking.send_multiple_booking_mail(@booking.location_id, booking_group)
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

    booking_buffer_params[:bookings].each do |pos, buffer_params|
      staff_code = nil
      new_booking_params = buffer_params.except(:client_first_name, :client_last_name, :client_phone, :client_email, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_gender, :staff_code)
      @booking = Booking.new(new_booking_params)

      if @company_setting.staff_code
        if !buffer_params[:staff_code].blank? && StaffCode.where(company_id: current_user.company_id, code: buffer_params[:staff_code]).count > 0
          staff_code = StaffCode.where(company_id: current_user.company_id, code: buffer_params[:staff_code]).first.id
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
          @client.gender = buffer_params[:client_gender]
          @client.save
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
          @client.gender = buffer_params[:client_gender]
          @client.save
          if User.find_by_email(@client.email)
            new_booking_params[:user_id] = User.find_by_email(@client.email).id
          end
        else
          if !buffer_params[:client_email].nil?
            if buffer_params[:client_email].empty?
              if Client.where(email: '', company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => buffer_params[:client_first_name]+' '+buffer_params[:client_last_name]).count > 0
                client = Client.where(email: '', company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).where("CONCAT(first_name, ' ', last_name) = :s", :s => buffer_params[:client_first_name]+' '+buffer_params[:client_last_name]).first
                @booking.client = client
              else
                client = Client.new(email: buffer_params[:client_email], first_name: buffer_params[:client_first_name], last_name: buffer_params[:client_last_name], phone: buffer_params[:client_phone], address: buffer_params[:client_address], district: buffer_params[:client_district], city: buffer_params[:client_city], birth_day: buffer_params[:client_birth_day], birth_month: buffer_params[:client_birth_month], birth_year: buffer_params[:client_birth_year], age: buffer_params[:client_age], gender: buffer_params[:client_gender], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id)
                if client.save
                  @booking.client = client
                end
              end
            else
              if Client.where(email: buffer_params[:client_email], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).count > 0
                client = Client.where(email: buffer_params[:client_email], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id).first
                @booking.client = client
              else
                client = Client.new(email: buffer_params[:client_email], first_name: buffer_params[:client_first_name], last_name: buffer_params[:client_last_name], phone: buffer_params[:client_phone], address: buffer_params[:client_address], district: buffer_params[:client_district], city: buffer_params[:client_city], birth_day: buffer_params[:client_birth_day], birth_month: buffer_params[:client_birth_month], birth_year: buffer_params[:client_birth_year], age: buffer_params[:client_age], gender: buffer_params[:client_gender], company_id: ServiceProvider.find(buffer_params[:service_provider_id]).company.id)
                if client.save
                  @booking.client = client
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

      if @booking.save
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
          :prepayed => prepayed
        }

        BookingHistory.create(booking_id: @booking.id, action: "Creada por Calendario", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: current_user.id, staff_code_id: staff_code)
      else
        @errors << {
            :booking => pos,
            :errors => @booking.errors.full_messages
          }
      end
    end
    respond_to do |format|
      if @bookings.length > 1
        Booking.send_multiple_booking_mail(@booking.location_id, booking_group)
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
    new_booking_params = booking_params.except(:client_first_name, :client_last_name, :client_phone, :client_email, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_gender, :staff_code, :deal_code)
    if @company_setting.staff_code
      if booking_params[:staff_code] && !booking_params[:staff_code].empty? && StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code]).count > 0
        staff_code = StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code]).first.id
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
        @client.gender = booking_params[:client_gender]
        @client.save
        if User.find_by_email(@client.email)
          new_booking_params[:user_id] = User.find_by_email(@client.email).id
        end
      else
        render :json => { :errors => ["El cliente no está registrado o no puede reservar."] }, :status => 422
        return
      end
    else
      if !booking_params[:client_id].nil? && !booking_params[:client_id].empty?
        @client = Client.find(booking_params[:client_id])
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
        @client.gender = booking_params[:client_gender]
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
              client = Client.new(email: booking_params[:client_email], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], address: booking_params[:client_address], district: booking_params[:client_district], city: booking_params[:client_city], birth_day: booking_params[:client_birth_day], birth_month: booking_params[:client_birth_month], birth_year: booking_params[:client_birth_year], age: booking_params[:client_age], gender: booking_params[:client_gender], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
              if client.save
                @booking.client = client
              end
            end
          else
            if Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).count > 0
              client = Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).first
              @booking.client = client
            else
              client = Client.new(email: booking_params[:client_email], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], address: booking_params[:client_address], district: booking_params[:client_district], city: booking_params[:client_city], birth_day: booking_params[:client_birth_day], birth_month: booking_params[:client_birth_month], birth_year: booking_params[:client_birth_year], age: booking_params[:client_age], gender: booking_params[:client_gender], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
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
        BookingHistory.create(booking_id: @booking.id, action: "Creada por Calendario", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: current_user.id, staff_code_id: staff_code)
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
    new_booking_params = booking_params.except(:client_first_name, :client_last_name, :client_phone, :client_email, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_gender, :staff_code, :deal_code)
    if @company_setting.staff_code
      if booking_params[:staff_code] && !booking_params[:staff_code].empty? && StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code]).count > 0
        staff_code = StaffCode.where(company_id: current_user.company_id, code: booking_params[:staff_code]).first.id
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
        @client.gender = booking_params[:client_gender]
        @client.save
        if User.find_by_email(@client.email)
          new_booking_params[:user_id] = User.find_by_email(@client.email).id
        end
      elsif !booking_params[:client_id].nil? && booking_params[:client_id].empty?
        render :json => { :errors => ["El cliente no está registrado o no puede reservar."] }, :status => 422
        return
      end
    else
      if !booking_params[:client_id].nil? && !booking_params[:client_id].empty?
        @client = Client.find(booking_params[:client_id])
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
        @client.gender = booking_params[:client_gender]
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
              client = Client.new(email: booking_params[:client_email], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], address: booking_params[:client_address], district: booking_params[:client_district], city: booking_params[:client_city], birth_day: booking_params[:client_birth_day], birth_month: booking_params[:client_birth_month], birth_year: booking_params[:client_birth_year], age: booking_params[:client_age], gender: booking_params[:client_gender], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
              if client.save
                new_booking_params[:client_id] = client.id
              end
            end
          else
            if Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).count > 0
              client = Client.where(email: booking_params[:client_email], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id).first
              new_booking_params[:client_id] = client.id
            else
              client = Client.new(email: booking_params[:client_email], first_name: booking_params[:client_first_name], last_name: booking_params[:client_last_name], phone: booking_params[:client_phone], address: booking_params[:client_address], district: booking_params[:client_district], city: booking_params[:client_city], birth_day: booking_params[:client_birth_day], birth_month: booking_params[:client_birth_month], birth_year: booking_params[:client_birth_year], age: booking_params[:client_age], gender: booking_params[:client_gender], company_id: ServiceProvider.find(booking_params[:service_provider_id]).company.id)
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
    end
    if ServiceProvider.where(:id => booking_params[:service_provider_id])
      new_booking_params[:location_id] = ServiceProvider.find(booking_params[:service_provider_id]).location.id
    end
    respond_to do |format|
      if @booking.update(new_booking_params)
        u = @booking
        if u.warnings then warnings = u.warnings.full_messages else warnings = [] end
        @booking_json = { :id => u.id, :start => u.start, :end => u.end, :service_id => u.service_id, :service_provider_id => u.service_provider_id, :status_id => u.status_id, :first_name => u.client.first_name, :last_name => u.client.last_name, :email => u.client.email, :phone => u.client.phone, :notes => u.notes,  :company_comment => u.company_comment, :provider_lock => u.provider_lock, :service_name => u.service.name, :warnings => warnings }
        BookingHistory.create(booking_id: @booking.id, action: "Modificada por Calendario", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: current_user.id, staff_code_id: staff_code)
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
    status = Status.find_by(:name => 'Cancelado').id
    @booking.update(status_id: status)
    # @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { render :json => @booking }
    end
  end

  def booking_history
    staff_code = '-'
    user = '-'
    bookings = []
    BookingHistory.where(booking_id: params[:booking_id]).order(created_at: :desc).each do |booking_history|
      if current_user.role_id == Role.find_by_name('Administrador General').id || current_user.role_id == Role.find_by_name('Administrador Local').id
        if booking_history.staff_code
          staff_code = booking_history.staff_code.staff
        end
        user = 'Usuario no registrado'
        if booking_history.user_id && booking_history.user_id > 0 && booking_history.user
          user = booking_history.user.email
        end
      end
      bookings.push( { action: booking_history.action, start: booking_history.start, service: booking_history.service.name, provider: booking_history.service_provider.public_name, status: booking_history.status.name, user: user, staff_code: staff_code } )
    end
    render :json => bookings
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
    statusIcon = [" blocked", " reserved", " confirmed", " completed", " payed", " cancelled", " noshow", " break"]
    backColors = ["#cacaca", "#77d0fa", "#fbe09f", "#fab5fb", "#adf0d1", "#FAFCAF", "#fbc1b3", "#a6a5a5"]
    textColors = ["#707070", "#0b587d", "#a78a47", "#8e508f", "#4c8b6e", "#505205", "#a15240", "#737373"]
    if params[:provider] != "0"
      @providers = ServiceProvider.where(:id => params[:provider])
    else
      @providers = ServiceProvider.where(:location_id => params[:location], active: true)
    end

    start_date = DateTime.parse(params[:start])
    end_date = DateTime.parse(params[:end])

    events = Array.new

    @bookings = Booking.where(:service_provider_id => @providers).where('(bookings.start,bookings.end) overlaps (date ?,date ?)', end_date, start_date).order(:start)
    @bookings.each do |booking|
      if booking.status_id != Status.find_by_name('Cancelado').id
        event = Hash.new
        booking.provider_lock ? providerLock = '-lock' : providerLock = '-unlock'
        booking.web_origin ? originClass = 'origin-web' : originClass = 'origin-manual'
        originClass += providerLock + statusIcon[booking.status_id]

        title = ''
        qtip = ''
        phone = ''
        email = ''
        comment = ''
        prepayed = ''

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

        if booking.client.phone
          phone = booking.client.phone
        end

        if booking.client.email
          email = booking.client.email
        end

        if booking.company_comment
          comment = booking.company_comment
        end

        if !booking.payed_booking.nil? && booking.payed
          prepayed = 'Sí'
        else
          prepayed = 'No'
        end

        event = {
          id: booking.id,
          title: title,
          allDay: false,
          start: booking.start,
          end: booking.end,
          resourceId: booking.service_provider_id,
          textColor: textColors[booking.status_id],
          borderColor: textColors[booking.status_id],
          backgroundColor: backColors[booking.status_id],
          className: originClass,
          title_qtip: qtip,
          time_qtip: booking.start.strftime("%H:%M") + ' - ' + booking.end.strftime("%H:%M"),
          service_qtip: booking.service.name,
          phone_qtip: phone,
          email_qtip: email,
          comment_qtip: comment,
          prepayed_qtip: prepayed
        }
        events.push(event)
      end
    end
    @breaks = ProviderBreak.where(:service_provider_id => @providers).where('(provider_breaks.start,provider_breaks.end) overlaps (date ?,date ?)', end_date, start_date).order(:start)
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
        textColor: textColors[7],
        borderColor: textColors[7],
        backgroundColor: backColors[7]
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
        start: start_date,
        end: end_date,
        resourceId: provider.id,
        textColor: textColors[0],
        borderColor: textColors[0],
        backgroundColor: backColors[0]
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
          start: time_end,
          end: time_start,
          resourceId: provider.id,
          textColor: textColors[0],
          borderColor: textColors[0],
          backgroundColor: backColors[0]
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
    

    @bookings = []
    @errors = []
    @blocked_bookings = []

    @location_id = params[:location]
    @selectedLocation = Location.find(@location_id)
    @company = Location.find(params[:location]).company
    cancelled_id = Status.find_by(name: 'Cancelado').id

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    if @company.company_setting.client_exclusive
      if(params[:client_id])
        client = Client.find(params[:client_id])
      elsif Client.where(identification_number: params[:identification_number], company_id: @company).count > 0
        client = Client.where(identification_number: params[:identification_number], company_id: @company).first
        client.email = params[:email]
        client.phone = params[:phone]
        client.save
        if client.errors
          puts client.errors.full_messages.inspect
        end
      else
        @errors << "No estás ingresado como cliente"
        render layout: "workflow"
        return
      end
    else
      if(params[:client_id])
        client = Client.find(params[:client_id])
      elsif Client.where(email: params[:email], company_id: @company).count > 0
        client = Client.where(email: params[:email], company_id: @company).first
        client.first_name = params[:firstName]
        client.last_name = params[:lastName]
        client.phone = params[:phone]
        client.save
        if client.errors
          puts client.errors.full_messages.inspect
        end
      else
        client = Client.new(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], company_id: @company.id)
        client.save
        if client.errors
          puts client.errors.full_messages.inspect
        end
      end
    end

    if params[:address] && !params[:address].empty?
      params[:comment] += ' - Dirección del cliente (donde se debe realizar el servicio): ' + params[:address]
    end

    booking_data = JSON.parse(params[:bookings], symbolize_names: true)

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

    booking_data.each do |buffer_params|
      block_it = false
      service_provider = ServiceProvider.find(buffer_params[:provider])
      service = Service.find(buffer_params[:service])
      service_provider.bookings.each do |provider_booking|
        unless provider_booking.status_id == cancelled_id
          if (provider_booking.start.to_datetime - buffer_params[:end].to_datetime) * (buffer_params[:start].to_datetime - provider_booking.end.to_datetime) > 0
            if !service.group_service || buffer_params[:service].to_i != provider_booking.service_id
              @errors << "Lo sentimos, la hora " + I18n.l(buffer_params[:start].to_datetime) + " con " + service_provider.public_name + " ya fue reservada por otro cliente."
              block_it = true
              next
            elsif service.group_service && buffer_params[:service].to_i == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => buffer_params[:start].to_datetime).count >= service.capacity
              @errors << "Lo sentimos, la capacidad del servicio grupal " + service.name + " llegó a su límite."
              block_it = true
              next
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
          provider_lock: buffer_params[:provider_lock]
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
            provider_lock: buffer_params[:provider_lock]
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
            provider_lock: buffer_params[:provider_lock]
          )
        end
      end

      

      @booking.price = service.price
      @booking.max_changes = @company.company_setting.max_changes
      @booking.booking_group = booking_group

      if deal
        @booking.deal = deal
      end

      if block_it
        @blocked_bookings << @booking
      else
        @bookings << @booking
      end

      #
      #   PAGO EN LÍNEA DE RESERVA
      #
      if(params[:payment] == "1")

        #Check if all payments are payable
        #Apply grouped discount
        if !service.online_payable
          group_payment = false
          # Redirect to error
        end

        #trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
        num_amount = service.price
        if service.has_discount
          num_amount = (service.price - service.price*service.discount/100).round;
        end
        final_price = final_price + num_amount

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
          BookingHistory.create(booking_id: @booking.id, action: "Creada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user)
        else
          @errors << @booking.errors.full_messages
        end
      end

    end


    

    #If they can be payed, redirect to payment_process,
    #then check for error or send notifications mails.
    if group_payment
      trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
      amount = sprintf('%.2f', final_price)
      payment_method = params[:mp]
      req = PuntoPagos::Request.new()
      resp = req.create(trx_id, amount, payment_method)
      if resp.success?
        proceed_with_payment = true
        @bookings.each do |booking|
          booking.trx_id = trx_id
          booking.token = resp.get_token
          if booking.save
            current_user ? user = current_user.id : user = 0            
            BookingHistory.create(booking_id: booking.id, action: "Creada por Cliente", start: booking.start, status_id: booking.status_id, service_id: booking.service_id, service_provider_id: booking.service_provider_id, user_id: user)           
          else
            @errors = booking.errors.full_messages
            proceed_with_payment = false
          end
        end
        @blocked_bookings.each do |b_booking|
          b_booking.save
        end

        #Check for errors before starting payment
        if @errors.length > 0 and @blocked_bookings.count > 0
          redirect_to book_error_path(bookings: @bookings.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: "payment", blocked_bookings: @blocked_bookings.map{|b| b.id})
          return
        end

        if proceed_with_payment
          PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: amount, details: "Pago de varios servicios a la empresa " +@company.name+" (" + @company.id.to_s + "). trx_id: "+trx_id+" - mp: "+@company.id.to_s+". Resultado: Se procesa")
          redirect_to resp.payment_process_url and return
        else
          puts resp.get_error
          redirect_to punto_pagos_failure_path and return
        end
      else
        puts resp.get_error
        redirect_to punto_pagos_failure_path and return
      end
    end

    str_payment = "book"
    if group_payment
      str_payment = "payment"
    end

    if @errors.length > 0 and booking_data.length > 0
      redirect_to book_error_path(bookings: @bookings.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: str_payment, blocked_bookings: @blocked_bookings.map{|b| b.id})
      return
    end

    if @bookings.length > 1
      Booking.send_multiple_booking_mail(@location_id, booking_group)
    end

    render layout: "workflow"
  end

  def book_error
    @location = Location.find(params[:location])
    @company = @location.company
    @client = Client.find(params[:client])
    @tried_bookings = []
    if(params[:bookings])
      @tried_bookings = Booking.find(params[:bookings])
    end
    @payment = params[:payment]
    @blocked_bookings = Booking.find(params[:blocked_bookings])
    @errors = params[:errors]
    @bookings = []

    #If payed, delete them all.
    if @payment == "payment"
      @blocked_bookings.each do |booking|
        booking.delete
      end
    else #Create fake bookings and delete the real ones
      @tried_bookings.each do |booking|
        fake_booking = Booking.new(booking.attributes.to_options)
        @bookings << fake_booking
        booking.delete
      end
    end

    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def remove_bookings
    @bookings = Booking.find(params[:bookings].split())
    @bookings.each do |booking|
      booking.destroy
    end

    # => Domain parser
    host = request.host_with_port
    @url = Company.find(params[:company]).web_address + '.' + host[host.index(request.domain)..host.length]

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
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
    booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0
    if (booking_start <=> now) < 1 or @booking.max_changes <= 0
      redirect_to blocked_edit_path(:id => @booking.id)
      return
    end

    #Revisar si fue pagada en línea.
    #Si lo fue, revisar política de modificación.
    if @booking.payed || !@booking.payed_booking.nil?
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

    if mobile_request?
      @service = @booking.service
      @provider = @booking.service_provider
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
                    provider_free = false
                    break
                  elsif @service.group_service && @service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => @service.id, :start => start_time_block).count >= @service.capacity
                    provider_free = false
                    break
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
    if(params[:online])
      @reason = "online"
    end
    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "workflow"
  end

  def edit_booking_post
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company
    @selectedLocation = Location.find(@booking.location_id)
    max_changes = @booking.max_changes - 1
    if @booking.update(start: params[:start], end: params[:end], max_changes: max_changes)
      #flash[:notice] = "Reserva actualizada exitosamente."
      # BookingMailer.update_booking(@booking)
      current_user ? user = current_user.id : user = 0
      BookingHistory.create(booking_id: @booking.id, action: "Modificada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user)
    else
      #flash[:alert] = "Hubo un error actualizando tu reserva. Inténtalo nuevamente."
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
    @selectedLocation = Location.find(@booking.location_id)
    if @booking.update(:status => Status.find_by(:name => 'Confirmado'))
      current_user ? user = current_user.id : user = 0
      BookingHistory.create(booking_id: @booking.id, action: "Confirmada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user)
    end
    render layout: 'workflow'
  end

  def blocked_cancel
    @booking = Booking.find(params[:id])
    @company = Location.find(@booking.location_id).company
    @reason = "company"
    if(params[:online])
      @reason = "online"
      if !params[:only_booking].nil? and params[:only_booking]
        @reason = "only_booking"
      end
    end
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
      @selectedLocation = Location.find(@booking.location_id)

      now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
      booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0

      if (booking_start <=> now) < 1
        redirect_to blocked_cancel_path(:id => @booking.id)
        return
      end

      # Revisar si fue pagada en línea.
      # Si lo fue, revisar política de modificación.
      if @booking.payed || !@booking.payed_booking.nil?
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


      status = Status.find_by(:name => 'Cancelado').id

      payed = false

      if @booking.update(status_id: status, payed: payed)

        if !@booking.payed_booking.nil?
          @booking.payed_booking.canceled = true
          @booking.payed_booking.save
        end
        #flash[:notice] = "Reserva cancelada exitosamente."
        # BookingMailer.cancel_booking(@booking)
        current_user ? user = current_user.id : user = 0
        BookingHistory.create(booking_id: @booking.id, action: "Cancelada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user)
      else
        flash[:alert] = "Hubo un error cancelando tu reserva. Inténtalo nuevamente."
        @errors = @booking.errors
      end

    end

    @company = Location.find(@booking.location_id).company

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

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

      #Revisar si fue pagada en línea.
      #Si lo fue, revisar política de modificación.
      @bookings.each do |booking|
        if booking.payed || !booking.payed_booking.nil?
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
      #Fin pagadas

      booking_start = DateTime.parse(booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0

      if (booking_start <=> now) < 1
        flash[:alert] = "No fue posible cancelar"
        redirect_to root_path
        return
      end
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
      status = Status.find_by(:name => 'Cancelado').id


      @bookings.each do |booking|
        if booking.payed || !booking.payed_booking.nil?
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
      #Fin pagadas

      @bookings.each do |book|
        if book.update(status_id: status)
          current_user ? user = current_user.id : user = 0
          BookingHistory.create(booking_id: book.id, action: "Cancelada por Cliente", start: book.start, status_id: book.status_id, service_id: book.service_id, service_provider_id: book.service_provider_id, user_id: user)
        else
          logger.info book.errors
        end
      end

    end

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]
    render layout: 'workflow'
  end

  def transfer_error_cancel
    if params[:company_id]
      @company = Company.find(params[:company_id])
      render layout: 'workflow'
    else
      redirect_to root_without_subdomain
      return
    end
  end

  def check_user_cross_bookings
    require 'date'
    if !params[:user_id].blank?
      bookings = Booking.where(:user_id => params[:user_id], :status_id => [Status.find_by(:name => 'Reservado'), Status.find_by(:name => 'Pagado'), Status.find_by(:name => 'Confirmado')])
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

  def provider_hours
    @service_provider = ServiceProvider.find(params[:service_provider_id])
    block_length = @service_provider.block_length * 60
    now = params[:provider_date].to_date
    table_rows = []

    provider_times = @service_provider.provider_times.where(day_id: now.cwday).order(:open)

    if provider_times.length > 0

      open_provider_time = provider_times.first.open
      close_provider_time = provider_times.last.close

      provider_open = provider_times.first.open
      while (provider_open <=> close_provider_time) < 0 do
        provider_close = provider_open + block_length

        table_row = [provider_open.strftime('%R'), nil, nil, nil]
        last_row = table_rows.length - 1

        block_open = DateTime.new(now.year, now.mon, now.mday, provider_open.hour, provider_open.min)
        block_close = DateTime.new(now.year, now.mon, now.mday, provider_close.hour, provider_close.min)

        service_name = 'Descanso por Horario'
        client_name = '...'
        client_phone = '...'

        in_provider_time = false
        provider_times.each do |provider_time|
          if (provider_time.open - provider_close)*(provider_open - provider_time.close) > 0
            in_provider_time = true
            service_name = ''
            client_name = ''
            client_phone = ''
            break
          end
        end
        in_provider_booking = false
        if in_provider_time
          Booking.where(service_provider: @service_provider, status_id: Status.where(name: ['Reservado', 'Confirmado','Pagado','Asiste']).pluck(:id), start: now.beginning_of_day..now.end_of_day).order(:start).each do |booking|
            if (booking.start.to_datetime - block_close)*(block_open - booking.end.to_datetime) > 0
              in_provider_booking = true
              service_name = booking.service.name
              client_name = booking.client.first_name + ' ' + booking.client.last_name
              client_phone = booking.client.phone
              break
            end
          end
        end
        in_provider_break = false
        if in_provider_time && !in_provider_booking
          ProviderBreak.where(service_provider: @service_provider, start: now.beginning_of_day..now.end_of_day).each do |provider_break|
            if (provider_break.start.to_datetime - block_close)*(block_open - provider_break.end.to_datetime) > 0
              in_provider_booking = true
              service_name = "Bloqueo: "+provider_break.name
              client_name = '...'
              client_phone = '...'
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

            if (service_name != '') && (service_name == table_rows[last_row][1]) && (client_name == (table_rows[last_row][2]))

              service_name = 'Continuación...'
              client_name = '...'
              client_phone = '...'
            end
          end
        end

        table_row << service_name
        table_row << client_name
        table_row << client_phone
        table_row.compact!

        table_rows.append(table_row)

        provider_open += block_length
      end
    end
    respond_to do |format|
      format.json { render :json => table_rows }
    end
  end

  def optimizer_hours
    @hours_array = []

    # Generals
    array_length = if params[:resultsLength] then params[:resultsLength].to_i else 6 end
    local = Location.find(params[:local])
    company_setting = local.company.company_setting
    cancelled_id = Status.find_by(name: 'Cancelado').id
    serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)

    if params[:start_date] and params[:start_date] != ""
      now = params[:start_date].to_datetime
      now = now - company_setting.before_booking.hours
    end

    # Pointers
    dateTimePointer = local.location_times.where(day_id: now.cwday).order(:open).first.open
    dateTimePointer = DateTime.new(now.year, now.mon, now.mday, dateTimePointer.hour, dateTimePointer.min)

    while @hours_array.length < array_length and (dateTimePointer <=> now + company_setting.after_booking.month) == -1
      # Pointers
      serviceStaffPos = 0
      bookings = []
      while serviceStaffPos < serviceStaff.length and (dateTimePointer <=> now + company_setting.after_booking.month) == -1
        service_valid = false
        service = Service.find(serviceStaff[serviceStaffPos][:service])

        minHour = now
        if not params[:admin]
          minHour += company_setting.before_booking.hours
        end
        if dateTimePointer >= minHour
          service_valid = true
        end

        # Hora dentro del horario del local
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
          providers = []
          if serviceStaff[serviceStaffPos][:provider] != "0"
            providers << ServiceProvider.find(serviceStaff[serviceStaffPos][:provider])
          else
            providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }
          end

          providers.each do |provider|
            service_valid = false
            provider.provider_times.where(day_id: dateTimePointer.cwday).each do |provider_time|
              provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
              provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

              if provider_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= provider_close
                service_valid = true
                break
              end
            end

            # Provider breaks
            if service_valid
              provider.provider_breaks.each do |provider_break|
                if (provider_break.start.to_datetime - (dateTimePointer + service.duration.minutes))*(dateTimePointer - provider_break.end.to_datetime) > 0
                  service_valid = false
                  break
                end
              end
            end

            # Cross Booking
            if service_valid
              Booking.where(service_provider_id: provider.id, start: dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |provider_booking|
                unless provider_booking.status_id == cancelled_id
                  if (provider_booking.start.to_datetime - (dateTimePointer + service.duration.minutes)) * (dateTimePointer - provider_booking.end.to_datetime) > 0
                    if !service.group_service || service.id != provider_booking.service_id
                      service_valid = false
                      break
                    elsif service.group_service && service.id == provider_booking.service_id && provider.bookings.where(service_id: service.id, start: dateTimePointer).count >= service.capacity
                      service_valid = false
                      break
                    end
                  end
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
                local.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
                  if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - (dateTimePointer + service.duration.minutes)) * (dateTimePointer - location_booking.end.to_datetime) > 0
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
                :discount => service.discount
              }
              serviceStaffPos += 1
              dateTimePointer += service.duration.minutes
              break
            end
          end
        end

        if !service_valid
          dateTimePointer += service.duration.minutes
          serviceStaffPos = 0
          bookings = []
        end
      end

      if bookings.length > 0 and (dateTimePointer <=> now + company_setting.after_booking.month) == -1
        @hours_array << {
          :date => I18n.l(bookings[0][:start].to_date, format: :day_short),
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
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

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
      params.require(:booking).permit(:start, :end, :notes, :service_provider_id, :service_id, :price, :user_id, :status_id, :promotion_id, :client_id, :client_first_name, :client_last_name, :client_email, :client_phone, :confirmation_code, :company_comment, :web_origin, :provider_lock, :send_mail, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_gender, :staff_code, :deal_code)
    end

    def booking_buffer_params
      params.permit(bookings: [:start, :end, :notes, :service_provider_id, :service_id, :price, :user_id, :status_id, :promotion_id, :client_id, :client_first_name, :client_last_name, :client_email, :client_phone, :confirmation_code, :company_comment, :web_origin, :provider_lock, :send_mail, :client_identification_number, :client_address, :client_district, :client_city, :client_birth_day, :client_birth_month, :client_birth_year, :client_age, :client_gender, :staff_code])
    end
end
