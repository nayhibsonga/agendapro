class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!, except: [:location_data, :location_time, :get_available_time, :location_districts]
  before_action :quick_add, except: [:location_data, :location_time, :get_available_time, :location_districts]
  load_and_authorize_resource
  layout "admin", except: [:change_location_order]

  # GET /locations
  # GET /locations.json
  def index
    if current_user.role_id == Role.find_by_name('Super Admin').id
      @locations = Location.where(company_id: Company.where(owned: false).pluck(:id)).order(order: :asc)
    else
      @locations = Location.where(company_id: current_user.company_id, :active => true).order(order: :asc).accessible_by(current_ability)
    end
  end

  def inactive_index
    @locations = Location.where(company_id: current_user.company_id, :active => false).order(:name).accessible_by(current_ability)
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new
    @location.company_id = current_user.company_id
    if current_user.role_id != Role.find_by_name("Super Admin").id
      if current_user.company.locations.where(active:true).count >= current_user.company.plan.locations
        redirect_to locations_path, alert: 'No puedes crear más locales con tu plan actual.'
        return
      end
    end
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)
    if current_user.role_id != Role.find_by_name("Super Admin").id
      @location.company_id = current_user.company_id
    end

    respond_to do |format|
      if @location.save
        flash[:notice] = 'Local actualizado exitosamente.'
        format.html { redirect_to locations_path }
        format.json { render :json => @location }
      else
        format.html { redirect_to locations_path, alert: 'No se pudo guardar el local.' }
        format.json { render :json => { :errors => @location.errors.full_messages }, :status => 422 }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    @location_times = Location.find(params[:id]).location_times
    @location_times.each do |location_time|
      location_time.location_id = nil
      location_time.save
    end
    @location = Location.find(params[:id])
    respond_to do |format|
      if @location.update(location_params)
        @location_times.destroy_all
        flash[:notice] = 'Local actualizado exitosamente.'
        format.html { redirect_to locations_path }
        format.json { render :json => @location }
      else
        @location_times.each do |location_time|
          location_time.location_id = @location.id
          location_time.save
        end
        format.html { redirect_to locations_path, alert: 'No se pudo guardar el local.' }
        format.json { render :json => { :errors => @location.errors.full_messages }, :status => 422 }
      end
    end
  end

  def activate
    @location.active = true
    if @location.save
      redirect_to inactive_locations_path, notice: "Local activado exitosamente."
    else
      redirect_to inactive_locations_path, notice: "No se pudo activar el local ya que el plan actual no lo permite, ¡mejóralo!"
    end
  end

  def deactivate
    @location.active = false
    if @location.save
      redirect_to locations_path, notice: "Local desactivado exitosamente."
    else
      redirect_to locations_path, notice: "No se pudo desactivar el local."
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end

  def location_data
    location = Location.find(params[:id])
    render :json => location
  end

  def location_districts
    location = Location.find(params[:id])
    render :json => { :districts => location.districts, :country => location.district.city.region.country.name, :region => location.district.city.region.name, :city => location.district.city.name }
  end

  def location_time
    location_time = Location.find(params[:id]).location_times
    render :json => location_time
  end

  def check_num_locations
    ok = 1
    if current_user.role_id != Role.find_by_name("Super Admin").id
      if current_user.company.locations.where(active:true).count >= current_user.company.plan.locations
        ok = 0
      end
    end
    render :json => {:ok => ok}
  end

  def get_available_time
    require 'date'
    if params[:provider] == "0"
      # Data
      service = Service.find(params[:service])
      service_duration = service.duration
      weekDate = Date.strptime(params[:date], '%Y-%m-%d')
      local = Location.find(params[:local])
      company_setting = CompanySetting.find(Company.find(local.company_id).company_setting)
      provider_breaks = ProviderBreak.where(:service_provider_id => local.service_providers.pluck(:id))
      cancelled_id = Status.find_by(name: 'Cancelado').id
      location_times_first = local.location_times.order(:open).first
      location_times_final = local.location_times.order(close: :desc).first

      @week_blocks = Hash.new
      # Week Blocks
      # {
      #   21-02-2014: [block_hour, block_hour, ...],
      #   22-02-2014: [block_hour, block_hour, ...]
      # }

      weekDate.upto(weekDate + 6) do |date|

        # Block Hour
        # {
        #   status: 'available/occupied/empty/past',
        #   hour: {
        #     start: '10:00',
        #     end: '10:30',
        #     provider: ''
        #   }
        # }

        available_time = Array.new

        # Variable Data
        day = date.cwday
        ordered_providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(date) }
        location_times = local.location_times.where(day_id: day).order(:open)

        # time_offset = 0

        if location_times.length > 0

          location_times_first_open = location_times_first.open
          location_times_final_close = location_times_final.close

          location_times_first_open_start = location_times_first_open

          while (location_times_first_open_start <=> location_times_final_close) < 0 do

            location_times_first_open_end = location_times_first_open_start + service_duration.minutes

            status = 'empty'
            hour = {
              :start => '',
              :end => '',
              :provider => ''
            }

            open_hour = location_times_first_open_start.hour
            open_min = location_times_first_open_start.min
            start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

            next_open_hour = location_times_first_open_end.hour
            next_open_min = location_times_first_open_end.min
            end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


            start_time_block = DateTime.new(date.year, date.mon, date.mday, open_hour, open_min)
            end_time_block = DateTime.new(date.year, date.mon, date.mday, next_open_hour, next_open_min)
            now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
            before_now = start_time_block - company_setting.before_booking / 24.0
            after_now = now + company_setting.after_booking * 30

            available_provider = ''
            ordered_providers.each do |provider|
              provider_time_valid = false
              provider_free = true
              provider.provider_times.where(day_id: day).each do |provider_time|
                if (provider_time.open - location_times_first_open_end)*(location_times_first_open_start - provider_time.close) > 0
                  # if provider_time.open > location_times_first_open_start
                  #   time_offset += (provider_time.open - location_times_first_open_start)/1.minutes
                  #   if time_offset < service_duration
                  #     location_times_first_open_start = provider_time.open
                  #     location_times_first_open_end = location_times_first_open_start + service_duration.minutes
                  #   end
                  # end
                  if provider_time.open <= location_times_first_open_start && provider_time.close >= location_times_first_open_end
                    provider_time_valid = true
                  # elsif provider_time.open <= location_times_first_open_start
                  #   location_times_first_open_start -= time_offset.minutes
                  #   location_times_first_open_end -= time_offset.minutes
                  #   time_offset = 0
                  # else
                  #   time_offset = time_offset % service_duration
                  #   location_times_first_open_start -= time_offset.minutes
                  #   location_times_first_open_end -= time_offset.minutes
                  #   time_offset = 0
                  end
                end
                break if provider_time_valid
              end
              if provider_time_valid
                if (before_now <=> now) < 1
                  status = 'past'
                elsif (after_now <=> end_time_block) < 1
                  status = 'past'
                else
                  status = 'occupied'
                  Booking.where(:service_provider_id => provider.id, :start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |provider_booking|
                    unless provider_booking.status_id == cancelled_id
                      if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
                        if !service.group_service || service.id != provider_booking.service_id
                          provider_free = false
                          break
                        elsif service.group_service && service.id == provider_booking.service_id && provider.bookings.where(:service_id => service.id, :start => start_time_block).count >= service.capacity
                          provider_free = false
                          break
                        end
                      end
                    end
                  end
                  if service.resources.count > 0
                    service.resources.each do |resource|
                      if !local.resource_locations.pluck(:resource_id).include?(resource.id)
                        provider_free = false
                        break
                      end
                      used_resource = 0
                      group_services = []
                      local.bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |location_booking|
                        if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
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
                        provider_free = false
                        break
                      end
                    end
                  end
                  ProviderBreak.where(:service_provider_id => provider.id).each do |provider_break|
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
                break if ['past','available'].include? status
              end
            end

            if ['past','available','occupied'].include? status
              hour = {
                :start => start_block,
                :end => end_block,
                :provider => available_provider
              }
            end

            block_hour = Hash.new

            block_hour[:status] = status
            block_hour[:hour] = hour

            available_time << block_hour
            location_times_first_open_start = location_times_first_open_start + service_duration.minutes
          end
          @week_blocks[date] = available_time
        end
      end

    else

      # Data
      service = Service.find(params[:service])
      service_duration = service.duration
      weekDate = Date.strptime(params[:date], '%Y-%m-%d')
      local = Location.find(params[:local])
      company_setting = CompanySetting.find(Company.find(local.company_id).company_setting)
      provider = ServiceProvider.find(params[:provider])
      provider_breaks = provider.provider_breaks
      cancelled_id = Status.find_by(name: 'Cancelado').id
      provider_times_first = provider.provider_times.order(:open).first
      provider_times_final = provider.provider_times.order(close: :desc).first

      @week_blocks = Hash.new
      # Week Blocks
      # {
      #   21-02-2014: [block_hour, block_hour, ...],
      #   22-02-2014: [block_hour, block_hour, ...]
      # }

      weekDate.upto(weekDate + 6) do |date|
        # Block Hour
        # {
        #   status: 'available/occupied/empty/past',
        #   hour: {
        #     start: '10:00',
        #     end: '10:30',
        #     provider: ''
        #   }
        # }

        available_time = Array.new

        # Variable Data
        day = date.cwday
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
              :end => '',
              :provider => ''
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

            start_time_block = DateTime.new(date.year, date.mon, date.mday, open_hour, open_min)
            end_time_block = DateTime.new(date.year, date.mon, date.mday, next_open_hour, next_open_min)
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
                Booking.where(:service_provider_id => provider.id, :start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |provider_booking|
                  unless provider_booking.status_id == cancelled_id
                    if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
                      if !service.group_service || service.id != provider_booking.service_id
                        provider_free = false
                        break
                      elsif service.group_service && service.id == provider_booking.service_id && provider.bookings.where(:service_id => service.id, :start => start_time_block).count >= service.capacity
                        provider_free = false
                        break
                      end
                    end
                  end
                end
                if service.resources.count > 0
                  service.resources.each do |resource|
                    if !local.resource_locations.pluck(:resource_id).include?(resource.id)
                      provider_free = false
                      break
                    end
                    used_resource = 0
                    group_services = []
                    local.bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |location_booking|
                      if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
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
                :end => end_block,
                :provider => available_provider
              }
            end

            block_hour = Hash.new

            block_hour[:status] = status
            block_hour[:hour] = hour

            available_time << block_hour
            provider_times_first_open_start = provider_times_first_open_end
          end
          @week_blocks[date] = available_time
        end
      end
    end

    respond_to do |format|
      format.html
      format.json { render :json => @week_blocks }
    end
  end

  def change_location_order
    array_result = Array.new
    params[:location_order].each do |pos, location_hash|
      location = Location.find(location_hash[:location])
      if location.update(:order => location_hash[:order])
        array_result.push({
          location: location.name,
          status: 'Ok'
        })
      else
        array_result.push({
          location: location.name,
          status: 'Error',
          errors: location.errors
        })
      end
    end
    render :json => array_result
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:name, :address, :second_address, :phone, :outcall, :longitude, :latitude, :company_id, :online_booking, :district_id, district_ids: [], location_times_attributes: [:id, :open, :close, :day_id, :location_id])
    end
end
