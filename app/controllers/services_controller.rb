class ServicesController < ApplicationController
  before_action :set_service, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!, except: [:services_data, :service_data, :get_providers, :location_services, :location_categorized_services, :get_promotions_popover, :get_online_discount_popover, :show_time_promo, :show_last_minute_promo, :last_minute_hours]
  before_action :quick_add, except: [:services_data, :service_data, :get_providers]
  before_action :verify_is_super_admin, only: [:manage_promotions, :manage_service_promotion]
  layout "admin", except: [:get_providers, :services_data, :service_data, :show_time_promo]
  load_and_authorize_resource

  # GET /services
  # GET /services.json
  def index
    if current_user.role_id == Role.find_by_name('Super Admin').id
      @services = Service.where(company_id: Company.where(owned: false).pluck(:id)).order(:order, :name)
      @service_categories = ServiceCategory.where(company_id: Company.where(owned: false).pluck(:id)).order(:order, :name)
    else
      @services = Service.where(company_id: current_user.company_id, :active => true).order(:order, :name)
      @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(:order, :name)
    end
  end

  def inactive_index
    @services = Service.where(company_id: current_user.company_id, :active => false).order(:order, :name)
    @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(:order, :name)
  end

  def activate
    @service.active = true
    @service.save
    redirect_to inactive_services_path
  end

  def deactivate
    @service.active = false
    @service.save
    redirect_to services_path
  end

  # GET /services/1
  # GET /services/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @service }
    end
  end

  # GET /services/new
  def new
    @service = Service.new
    @service.company_id = current_user.company_id
  end

  # GET /services/1/edit
  def edit

  end

  # POST /services
  # POST /services.json
  def create
    if service_params[:service_category_attributes]
      if service_params[:service_category_attributes][:name].nil?
        new_params = service_params.except(:service_category_attributes)
      else
        new_params = service_params.except(:service_category_id)
      end
    end
    @service = Service.new(new_params)
    if current_user.role_id != Role.find_by_name("Super Admin").id
      @service.company_id = current_user.company_id
    end

    respond_to do |format|
      if @service.save
        format.html { redirect_to services_path, notice: 'Servicio creado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @service }
      else
        format.html { render action: 'new' }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1
  # PATCH/PUT /services/1.json
  def update
    if service_params[:service_category_attributes]
      if service_params[:service_category_attributes][:name].nil?
        new_params = service_params.except(:service_category_attributes)
      else
        new_params = service_params.except(:service_category_id)
      end
    end
    if params[:promo_update]
      new_params = service_params
    end
    respond_to do |format|
      send_promo_notification = false
      if service_params[:price]
        if service_params[:price].to_f != @service.price.to_f
          @service.time_promo_active = false
          send_promo_notification = true
        end
      end
      if params[:promo_update]
        if @service.update(new_params)
          if @service.has_sessions
            @service.has_last_minute_discount = false
            @service.save
          end
          if send_promo_notification
            if @service.time_promo_active && @service.has_time_discount && !@service.active_service_promo_id.nil?
              AdminMailer.notify_promo_creation(@service)
            end
          end
          @service.check_online_discount
          format.html { redirect_to manage_promotions_path, notice: 'Servicio actualizado exitosamente.' }
          format.json { head :no_content }
        else
          format.html { render action: 'manage_service_promotion' }
          format.json { render json: @service.errors, status: :unprocessable_entity }
        end
      else
        if @service.update(new_params)
          if @service.has_sessions
            @service.has_last_minute_discount = false
            @service.save
          end
          if send_promo_notification
            if @service.time_promo_active && @service.has_time_discount && !@service.active_service_promo_id.nil?
              AdminMailer.notify_promo_creation(@service)
            end
          end
          @service.check_online_discount
          format.html { redirect_to services_path, notice: 'Servicio actualizado exitosamente.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @service.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service.destroy
    respond_to do |format|
      format.html { redirect_to services_url }
      format.json { head :no_content }
    end
  end

  def get_providers
    service = Service.find(params[:id])
    providers = service.service_providers.where(:active => true, online_booking: true).where('location_id = ?', params[:local]).order(:order, :public_name)
    if params[:admin_origin]
      providers = service.service_providers.where(:active => true).where('location_id = ?', params[:local]).order(:order, :public_name)
    end
    render :json => providers
  end

  def location_services
    categories = ServiceCategory.where(:company_id => Location.find(params[:location]).company_id).order(:order, :name)
    services = Service.where(:active => true).order(:order, :name).includes(:service_providers).where('service_providers.active = ?', true).where('service_providers.location_id = ?', params[:location]).order(:order, :name)

    services_hash = []

    services.each do |service|
      service_hash = service.attributes.to_options
      service_hash['service_category_name'] = service.service_category.name
      services_hash << service_hash
    end

    render :json => services_hash
  end

  def location_categorized_services

    location_resources = Location.find(params[:location]).resource_locations.pluck(:resource_id)
    service_providers = ServiceProvider.where(location_id: params[:location]).where(:active => true, online_booking: true).order(:order, :public_name)
    if params[:admin_origin]
      service_providers = ServiceProvider.where(location_id: params[:location]).where(:active => true).order(:order, :public_name)
    end

    categories = ServiceCategory.where(:company_id => Location.find(params[:location]).company_id).order(:order, :name)
    services = Service.where(:active => true, online_booking: true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(:order, :name)

    if params[:admin_origin]
      services = Service.where(:active => true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(:order, :name)
    end

    service_resources_unavailable = ServiceResource.where(service_id: services)
    if location_resources.any?
      if location_resources.length > 1
        service_resources_unavailable = service_resources_unavailable.where('resource_id NOT IN (?)', location_resources)
      else
        service_resources_unavailable = service_resources_unavailable.where('resource_id <> ?', location_resources)
      end
    end
    if service_resources_unavailable.any?
      if service_resources_unavailable.length > 1
        services = services.where('services.id NOT IN (?)', service_resources_unavailable.pluck(:service_id))
      else
        services = services.where('id <> ?', service_resources_unavailable.pluck(:service_id))
      end
    end

    categorized_services = Array.new
    categories.each do |category|
      services_array = Array.new
      services.each do |service|
        if service.service_category_id == category.id
          serviceJSON = service.attributes.merge({'name_with_small_outcall' => service.name_with_small_outcall })
          services_array.push(serviceJSON)
        end
      end
      service_hash = {
        :id => category.id,
        :category => category.name,
        :services => services_array
      }
      categorized_services.push(service_hash)
    end

    render :json => categorized_services
  end

  def service_data
    service = Service.find(params[:id])
    render :json => service
  end

  def services_data
    services = Service.where(:company_id => current_user.company_id).order(:order, :name)
    render :json => services
  end

  def change_services_order
    array_result = Array.new
    params[:services_order].each do |pos, service_hash|
      service = Service.find(service_hash[:service])
      if service.update(:order => service_hash[:order])
        array_result.push({
          service: service.name,
          status: 'Ok'
        })
      else
        array_result.push({
          service: service.name,
          status: 'Error',
          errors: service.errors
        })
      end
    end
    render :json => array_result
  end

  def set_service_promo_times

    #service_promo = ServicePromo.new

    #if params[:service_promo_id]
    #  service_promo = ServicePromo.find(params[:service_promo_id])
    #end

    @ret_arr = []

    @service = Service.find(params[:service_id])

    service_promo = nil

    if !@service.active_service_promo_id.nil?
      #Create a new one from last one, and create new promos from last ones.
      last_service_promo = ServicePromo.find(@service.active_service_promo_id)

      service_promo = ServicePromo.create(:service_id => @service.id, :max_bookings => last_service_promo.max_bookings, :morning_start => params[:morning_start], :morning_end => params[:morning_end], :afternoon_start => params[:afternoon_start], :afternoon_end => params[:afternoon_end], :night_start => params[:night_start], :night_end => params[:night_end])

      last_service_promo.promos.each do |old_promo|
        promo = Promo.create(:day_id => old_promo.day_id, :morning_discount => old_promo.morning_discount, :afternoon_discount => old_promo.afternoon_discount, :night_discount => old_promo.night_discount, :location_id => old_promo.location_id, :service_promo_id => service_promo.id)
      end

      @service.active_service_promo_id = service_promo.id

      if @service.save
        @ret_arr << "ok"
        @ret_arr << @service
        render :json => @ret_arr
      else
        @ret_arr << "error"
        @ret_arr << @service.errors
        render :json => @ret_arr
      end

    else
      #Create a service promo and promos from defaults.
      service_promo = ServicePromo.create(:service_id => @service.id, :max_bookings => 0, :morning_start => params[:morning_start], :morning_end => params[:morning_end], :afternoon_start => params[:afternoon_start], :afternoon_end => params[:afternoon_end], :night_start => params[:night_start], :night_end => params[:night_end])

      promo_time = @service.company.company_setting.promo_time

      locations = []

      @service.service_providers.each do |service_provider|
        if !locations.include?(service_provider.location)
          locations << service_provider.location
        end
      end

      locations.each do |location|
        Day.all.each do |day|
          promo = Promo.create(:day_id => day.id, :morning_discount => promo_time.morning_default, :afternoon_discount => promo_time.afternoon_default, :night_discount => promo_time.night_default, :location_id => location.id, :service_promo_id => service_promo.id)
        end
      end

      @service.active_service_promo_id = service_promo.id

      if @service.save
        @ret_arr << "ok"
        @ret_arr << @service
        render :json => @ret_arr
      else
        @ret_arr << "error"
        @ret_arr << @service.errors
        render :json => @ret_arr
      end

    end

  end

  def set_promotions

    @service = Service.find(params[:service_id])

    @promo_time = @service.company.company_setting.promo_time

    @locations = Location.where(id: params[:locations])

    @missingLocations = Location.where(id: ServiceProvider.where(id: @service.service_providers).pluck(:location_id)) - @locations

    @last_minute_locations = Location.where(id: params[:last_minute_locations])

    @missingLastMinuteLocations = Location.where(id: ServiceProvider.where(id: @service.service_providers).pluck(:location_id)) - @last_minute_locations

    array_result = []
    @promos = []
    @last_minute_promos = []
    @errors = []

    first_time_promo = true

    def_finish_date = DateTime.now + 2.years
    def_book_limit_date = DateTime.now + 2.years

    if params[:finish_date] && params[:finish_date] != ""
      def_finish_date = params[:finish_date].to_datetime
    end
    if params[:book_limit_date] && params[:book_limit_date] != ""
      def_book_limit_date = params[:book_limit_date].to_datetime
    end

    if @service.has_time_discount || !@service.active_service_promo_id.nil? || @service.time_promo_active
      first_time_promo = false
    else
      if !@service.active_service_promo_id.nil?
        if ServicePromo.find(@service.active_service_promo_id)
          first_time_promo = false
        end
      end
    end

    if @service.update(:has_last_minute_discount => params[:has_last_minute_discount], :has_time_discount => params[:has_time_discount])

      ###################
      # TIME PROMOTIONS #
      ###################

      #Create new ServicePromo with all it's promos and update active_service_promo

      if params[:has_time_discount]

        last_service_promo = nil
        if !@service.active_service_promo_id.nil?
          last_service_promo = ServicePromo.find(@service.active_service_promo_id)
        elsif !@service.service_promos.nil? && @service.service_promos.count > 0
          last_service_promo = @service.service_promos.order('created_at desc').first
        end

        promos_changed = false

        if !last_service_promo.nil?

          old_locations = last_service_promo.promos.order('location_id asc').pluck(:location_id).uniq
          new_locations = @locations.order('id asc').pluck(:id).uniq

          if !old_locations.eql?(new_locations)
            promos_changed = true
          else
            @locations.each do |location|
              for i in 1..7

                promo_count = Promo.where(:service_promo_id => last_service_promo.id, :day_id => i, :location_id => location.id, :morning_discount => params[:morning_discounts][i], :afternoon_discount => params[:afternoon_discounts][i], :night_discount => params[:night_discounts][i]).count

                if promo_count < 1
                  promos_changed = true
                  break
                end

              end
            end
          end

          #Alter promo if limit date is changed, but don't worry about finish date and stock limiting.
          if def_book_limit_date != last_service_promo.book_limit_date.to_datetime
            promos_changed = true
          end

          #Alter promo if times changed
          if ServicePromo.where(:id => last_service_promo.id, :morning_start => params[:morning_start], :morning_end => params[:morning_end], :afternoon_start => params[:afternoon_start], :afternoon_end => params[:afternoon_end], :night_start => params[:night_start], :night_end => params[:night_end]).count < 1

            promos_changed = true

          end

          #if params[:limit_booking] != last_service_promo.limit_booking
          #  promos_changed = true
          #end

        else
          promos_changed = true
        end

        if promos_changed

          if params[:reset_on_max_change]
            service_promo = ServicePromo.create(:service_id => @service.id, :max_bookings => params[:max_bookings], :morning_start => params[:morning_start], :morning_end => params[:morning_end], :afternoon_start => params[:afternoon_start], :afternoon_end => params[:afternoon_end], :night_start => params[:night_start], :night_end => params[:night_end], :finish_date => def_finish_date, :book_limit_date => def_book_limit_date, :limit_booking => params[:limit_booking])
          else
            if last_service_promo != nil
              service_promo = ServicePromo.create(:service_id => @service.id, :max_bookings => @service.active_promo_left_bookings, :morning_start => params[:morning_start], :morning_end => params[:morning_end], :afternoon_start => params[:afternoon_start], :afternoon_end => params[:afternoon_end], :night_start => params[:night_start], :night_end => params[:night_end], :finish_date => def_finish_date, :book_limit_date => def_book_limit_date, :limit_booking => params[:limit_booking])
            else
              service_promo = ServicePromo.create(:service_id => @service.id, :max_bookings => params[:max_bookings], :morning_start => params[:morning_start], :morning_end => params[:morning_end], :afternoon_start => params[:afternoon_start], :afternoon_end => params[:afternoon_end], :night_start => params[:night_start], :night_end => params[:night_end], :finish_date => def_finish_date, :book_limit_date => def_book_limit_date, :limit_booking => params[:limit_booking])
            end
          end

          @locations.each do |location|
            for i in 1..7

              promo = Promo.new
              promo.service_promo_id = service_promo.id
              promo.day_id = i
              promo.morning_discount = params[:morning_discounts][i]
              promo.afternoon_discount = params[:afternoon_discounts][i]
              promo.night_discount = params[:night_discounts][i]
              promo.location_id = location.id

              if promo.save
                @promos << promo
              else
                @errors << promo.errors
              end

            end
          end

          @service.active_service_promo_id = service_promo.id
          if @service.save

          else
            @errors << @service.errors
          end

        else

          @service.active_service_promo_id = last_service_promo.id

          if params[:reset_on_max_change]
            service_promo = ServicePromo.find(@service.active_service_promo_id)
            service_promo.max_bookings = params[:max_bookings]
          end

          service_promo.finish_date = def_finish_date
          service_promo.book_limit_date = def_book_limit_date
          service_promo.limit_booking = params[:limit_booking]


          if service_promo.save

          else
            @errors << service_promo.errors
          end

          if @service.save

          else
            @errors << @service.errors
          end

        end


      else

        @service.active_service_promo_id = nil
        if @service.save

        else
          @errors << @service.errors
        end
      end


      ##########################
      # LAST MINUTE PROMOTIONS #
      ##########################
      #If it has no promotions, create them.
      #Else, update each one.

      if params[:has_last_minute_discount]
        if !@service.has_sessions

          if @service.last_minute_promos.nil? || @service.last_minute_promos.count == 0

            @last_minute_locations.each do |last_minute_location|

                last_minute_promo = LastMinutePromo.new
                last_minute_promo.service_id = @service.id
                last_minute_promo.location_id = last_minute_location.id
                last_minute_promo.discount = params[:last_minute_discount]
                last_minute_promo.hours = params[:last_minute_hours]

                if last_minute_promo.save
                  @last_minute_promos << last_minute_promo
                else
                  @errors << last_minute_promo.errors
                end

            end

          else

            @last_minute_locations.each do |last_minute_location|


                last_minute_promo = LastMinutePromo.where(:service_id => @service.id, :location_id => last_minute_location.id).first

                if !last_minute_promo.nil?

                  last_minute_promo.discount = params[:last_minute_discount]
                  last_minute_promo.hours = params[:last_minute_hours]

                  if last_minute_promo.save
                    @last_minute_promos << last_minute_promo
                  else
                    @errors << last_minute_promo.errors
                  end

                else

                  last_minute_promo = LastMinutePromo.new
                  last_minute_promo.service_id = @service.id
                  last_minute_promo.location_id = last_minute_location.id
                  last_minute_promo.discount = params[:last_minute_discount]
                  last_minute_promo.hours = params[:last_minute_hours]

                  if last_minute_promo.save
                    @last_minute_promos << last_minute_promo
                  else
                    @errors << last_minute_promo.errors
                  end

                end


            end

            @missingLastMinuteLocations.each do |last_minute_location|
              last_minute_promos = LastMinutePromo.where(:service_id => @service.id, :location_id => last_minute_location.id)
              if !last_minute_promos.nil?
                last_minute_promos.delete_all
              end
            end

          end

        end
      end



      if @errors.length == 0
        array_result[0] = "ok"
        array_result[1] = @service
        array_result[2] = @promos
        array_result[3] = @last_minute_promos

        if first_time_promo
          #Send notification for promo_activation.
          AdminMailer.notify_promo_creation(@service)
        end

      else
        array_result[0] = "error"
        array_result[1] = @service
        array_result[2] = @errors
      end

    else

      @errors << @service.errors
      array_result[0] = "error"
      array_result[1] = @service
      array_result[2] = @errors

    end

    render :json => array_result

  end

  #For workflow popovers
  def get_promotions_popover
    @service = Service.find(params[:service_id])
    @service_promo = ServicePromo.where(:id => @service.active_service_promo_id)
    @location = Location.find(params[:location_id])
    @promos = []
    #if !(@service.has_discount && @service.discount > 0)
      @promos = Promo.where(:service_promo_id => @service.active_service_promo_id, :location_id => @location.id).order("day_id asc")
    #end
    respond_to do |format|
      format.html { render :partial => 'get_promotions_popover' }
      format.json { render json: @promos }
    end
  end

  def get_online_discount_popover
    @service = Service.find(params[:service_id])
    @promos = []
    respond_to do |format|
      format.html { render :partial => 'get_promotions_popover' }
      format.json { render json: @promos }
    end
  end

  #For Super Admin
  def manage_promotions
    @services = Service.where(:has_time_discount => true, :time_promo_active => false).order(:company_id, :name)
    @approvedServices = Service.where(:has_time_discount => true, :time_promo_active => true).order(:company_id, :name)
  end

  def manage_service_promotion
    @service = Service.find(params[:id])
    service_promo = ServicePromo.find(@service.active_service_promo_id)
    @location = service_promo.promos.first.location
  end

  def show_time_promo

    @service = Service.find(params[:id])
    @location = Location.find(params[:location_id])

    #Check existance of promo
    if !@service.has_time_discount || @service.service_promos.nil? || @service.active_service_promo_id.nil?
      flash[:alert] = "No existen promociones para el servicio buscado."
      redirect_to root_path
      return
    end

    #Check promo has stock
    if @service.active_service_promo.max_bookings < 1 && @service.active_service_promo.limit_booking
      flash[:alert] = "No queda stock para la promoción buscada."
      redirect_to root_path
      return
    end

    #Check promo hasn't expired
    if DateTime.now > @service.active_service_promo.finish_date || DateTime.now > @service.active_service_promo.book_limit_date
      flash[:alert] = "La promoción buscada ya expiró."
      redirect_to root_path
      return
    end


    @company = @service.company

    str_name = @service.name.gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')
    normalized_search = str_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

    #@relatedServices = Service.search(normalized_search).where(:time_promo_active => true, :has_time_discount => true, :company_id => CompanyEconomicSector.where(economic_sector_id: @company.economic_sectors).pluck(:company_id))

    @relatedPromos = []

    #Find services with similar name.

    query = Location.search_services(normalized_search).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true, id: PromoTime.where(:active => true).pluck(:company_setting_id)).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @location.latitude.to_s + ')^2 + (longitude - ' + @location.longitude.to_s + ')^2) < 0.25')


    query.each do |location|

      time_promo_services = []

      ServiceProvider.where(:active => true, :location_id => location.id).each do |service_provider|

        time_promo_services = service_provider.services.with_time_promotions

        time_promo_services.each do |service|

          if service.id != @service.id || location.id != @location.id
            #Check it has stock
            if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
              if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
                promo_detail = [service, location]
                if !@relatedPromos.include?(promo_detail)
                  @relatedPromos << promo_detail
                  #if !@locations.include?(s[0])
                  #@locations << s[0]
                end
              end
            end
          end
        end

        logger.debug time_promo_services.inspect

      end

    end


    #If there aren't enough services, find those with similar economic_sectors

    if @relatedPromos.count < 6

      #str_name = .gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

      #normalized_search = str_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

      query = Location.where(company_id: Company.where(:active => true, :owned => true).where(:id => CompanyEconomicSector.where(economic_sector_id: @company.economic_sectors).pluck(:company_id)).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true, id: PromoTime.where(:active => true).pluck(:company_setting_id)).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @location.latitude.to_s + ')^2 + (longitude - ' + @location.longitude.to_s + ')^2) < 0.25')


      query.each do |location|

        time_promo_services = []

        ServiceProvider.where(:active => true, :location_id => location.id).each do |service_provider|

          time_promo_services = service_provider.services.with_time_promotions

          time_promo_services.each do |service|

            if service.id != @service.id || location.id != @location.id
              #Check it has stock
              if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
                if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
                  promo_detail = [service, location]
                  if !@relatedPromos.include?(promo_detail)
                    @relatedPromos << promo_detail
                    #if !@locations.include?(s[0])
                    #@locations << s[0]
                  end
                end
              end
            end
          end

          logger.debug time_promo_services.inspect

        end

      end

    end


    # @relatedServices.each do |service|

    #   service_promo = ServicePromo.find(service.active_service_promo_id)
    #   locations = service_promo.promos.pluck(:location_id).uniq

    #   locations.each do |locationId|


    #       ServiceProvider.where(:active => true, :location_id => locationId).each do |service_provider|

    #         if normalized_search != ""
    #           time_promo_services = service_provider.services.with_time_promotions.search(normalized_search)
    #         else
    #           time_promo_services = service_provider.services.with_time_promotions
    #         end

    #         time_promo_services.each do |service|
    #           #Check it has stock

    #           if service.id != @service.id || locationId != @location.id
    #             if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
    #               if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
    #                 promo_detail = [service, Location.find(locationId)]
    #                 if !@relatedPromos.include?(promo_detail)
    #                   @relatedPromos << promo_detail
    #                   #if !@locations.include?(s[0])
    #                   #@locations << s[0]
    #                 end
    #               end
    #             end
    #           end
    #         end

    #         logger.debug time_promo_services.inspect

    #       end

    #   end
    # end

    # if @relatedPromos.count < 6
    #   if @relatedServices.count > 0

    #     @plusRelatedServices = Service.where(:time_promo_active => true, :has_time_discount => true, :company_id => CompanyEconomicSector.where(economic_sector_id: @company.economic_sectors).pluck(:company_id)).limit(6 - @relatedPromos.count)

    #     @plusRelatedServices.each do |service|

    #       service_promo = ServicePromo.find(service.active_service_promo_id)
    #       locations = service_promo.promos.pluck(:location_id).uniq

    #       locations.each do |locationId|


    #           ServiceProvider.where(:active => true, :location_id => locationId).each do |service_provider|

    #             if normalized_search != ""
    #               time_promo_services = service_provider.services.with_time_promotions.search(normalized_search)
    #             else
    #               time_promo_services = service_provider.services.with_time_promotions
    #             end

    #             time_promo_services.each do |service|
    #               #Check it has stock
    #               if service.id != @service.id || locationId != @location.id

    #                 if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
    #                   if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
    #                     promo_detail = [service, Location.find(locationId)]
    #                     if !@relatedPromos.include?(promo_detail)
    #                       @relatedPromos << promo_detail
    #                     end
    #                   end
    #                 end

    #               end


    #             end


    #           end


    #       end
    #     end

    #   else

    #     @plusRelatedServices = Service.where(:time_promo_active => true, :has_time_discount => true, :company_id => CompanyEconomicSector.where(economic_sector_id: @company.economic_sectors).pluck(:company_id))

    #     @plusRelatedServices.each do |service|
    #       service_promo = ServicePromo.find(service.active_service_promo_id)
    #       locations = service_promo.promos.pluck(:location_id).uniq
    #       locations.each do |locationId|

    #           ServiceProvider.where(:active => true, :location_id => locationId).each do |service_provider|

    #             if normalized_search != ""
    #               time_promo_services = service_provider.services.with_time_promotions.search(normalized_search)
    #             else
    #               time_promo_services = service_provider.services.with_time_promotions
    #             end

    #             time_promo_services.each do |service|

    #               if service.id != @service.id || locationId != @location.id
    #               #Check it has stock
    #                 if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
    #                   if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
    #                     promo_detail = [service, Location.find(locationId)]
    #                     if !@relatedPromos.include?(promo_detail)
    #                       @relatedPromos << promo_detail
    #                       #if !@locations.include?(s[0])
    #                       #@locations << s[0]
    #                     end
    #                   end
    #                 end
    #               end
    #             end

    #             logger.debug time_promo_services.inspect

    #           end


    #       end
    #     end

    #   end
    # end

    if @relatedPromos.count > 6
      @relatedPromos = @relatedPromos[0, 6]
    end

    if mobile_request?
      render layout: "promo"
    else
      render layout: "results"
    end

  end

  def show_last_minute_promo

    @service = Service.find(params[:id])
    @location = Location.find(params[:location_id])
    if !@service.has_time_discount || @service.service_promos.nil? || @service.active_service_promo_id.nil?
      flash[:alert] = "No existen promociones para el servicio buscado."
      redirect_to root_path
    end
    @company = @service.company

    str_name = @service.name.gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')
    normalized_search = str_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

    @relatedServices = Service.search(normalized_search).where(:has_time_discount => true, :company_id => CompanyEconomicSector.where(economic_sector_id: @company.economic_sectors).pluck(:company_id))

    @relatedPromos = []

    @relatedServices.each do |service|

      service_promo = ServicePromo.find(service.active_service_promo_id)
      locations = service_promo.promos.pluck(:location_id).uniq

      locations.each do |locationId|
        if service.id != @service.id || locationId != @location.id
          promo = [service, Location.find(locationId)]
          @relatedPromos << promo
        end
      end
    end

    if @relatedPromos.count < 6
      if @relatedServices.count > 0

        @plusRelatedServices = Service.where(:has_time_discount => true, :company_id => CompanyEconomicSector.where(economic_sector_id: @company.economic_sectors).pluck(:company_id)).limit(6 - @relatedPromos.count)

        @plusRelatedServices.each do |service|

          service_promo = ServicePromo.find(service.active_service_promo_id)
          locations = service_promo.promos.pluck(:location_id).uniq

          locations.each do |locationId|
            if service.id != @service.id || locationId != @location.id
              promo = [service, Location.find(locationId)]
              if !@relatedPromos.include?(promo)
                @relatedPromos << promo
              end
            end
          end
        end

      else

        @plusRelatedServices = Service.where(:has_time_discount => true, :company_id => CompanyEconomicSector.where(economic_sector_id: @company.economic_sectors).pluck(:company_id))

        @plusRelatedServices.each do |service|
          service_promo = ServicePromo.find(service.active_service_promo_id)
          locations = service_promo.promos.pluck(:location_id).uniq
          locations.each do |locationId|
            if service.id != @service.id || locationId != @location.id
              promo = [service, Location.find(locationId)]
              if !@relatedPromos.include?(promo)
                @relatedPromos << promo
              end
            end
          end
        end

      end
    end

    if @relatedPromos.count > 6
      @relatedPromos = @relatedPromos[0, 6]
    end

    render layout: "results"

  end

  def last_minute_hours
    @service = Service.find(params[:id])
    @location = Location.find(params[:location_id])
    @available_hours = @service.get_last_minute_available_hours(params[:service_provider_id], params[:location_id])
    respond_to do |format|
      format.html { render :partial => 'last_minute_hours' }
      format.json { render :json => @available_hours }
    end
  end

  def admin_update_promo
    #respond_to do |format|

    #end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_params
      params.require(:service).permit(:name, :price, :show_price, :duration, :outcall, :description, :group_service, :capacity, :waiting_list, :outcall, :online_payable, :must_be_paid_online, :online_booking, :has_discount, :discount, :comission_value, :comission_option, :company_id, :service_category_id, :has_sessions, :sessions_amount, :time_promo_active, :time_promo_photo, :promo_description, service_category_attributes: [:name, :company_id, :id],  :tag_ids => [], :service_provider_ids => [], :resource_ids => [])
    end
end
