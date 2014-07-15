class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!, except: [:location_data, :location_time, :get_available_time, :location_districts]
  before_action :quick_add, except: [:location_data, :location_time, :get_available_time, :location_districts]
  load_and_authorize_resource
  layout "admin", except: [:change_location_order]

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.where(company_id: current_user.company_id, :active => true).order(order: :asc).accessible_by(current_ability)
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
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)
    @location.company_id = current_user.company_id

    respond_to do |format|
      if @location.save
        format.html { redirect_to locations_path, notice: 'Local creado satisfactoriamente.' }
        format.json { render :json => @location }
      else
        format.html { render action: 'new' }
        format.json { render :json => { :errors => @location.errors.full_messages }, :status => 422 }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    @location = Location.find(params[:id])
    @location.location_times.destroy_all
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to locations_path, notice: 'Local actualizado satisfactoriamente.' }
        format.json { render :json => @location }
      else
        format.html { render action: 'edit' }
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

  def get_available_time
    require 'date'

    # Data
    service = Service.find(params[:service])
    service_duration = service.duration
    weekDate = Date.strptime(params[:date], '%Y-%m-%d')
    local = Location.find(params[:local])
    company_setting = CompanySetting.find(Company.find(local.company_id).company_setting)
    provider_breaks = ProviderBreak.where(:service_provider_id => params[:provider])
    cancelled_id = Status.find_by(name: 'Cancelado').id

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
      #     end: '10:30'
      #   }
      # }

      available_time = Array.new

      # Variable Data
      day = date.cwday
      provider_times = local.service_providers.find(params[:provider]).provider_times.where(day_id: day).order(:open)
      bookings = local.service_providers.find(params[:provider]).bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).order(:start)
      provider_times_first = local.service_providers.find(params[:provider]).provider_times.order(:open).first
      provider_times_final = local.service_providers.find(params[:provider]).provider_times.order(close: :desc).first

      # Empty Blocks before
      if provider_times.length > 0
        provider_times_first_open = provider_times_first.open
        provider_time_open = provider_times[0].open
        while (provider_times_first_open <=> provider_time_open) < 0 do
          block_hour = Hash.new

          status = 'empty'
          hour = {
            :start => '',
            :end => ''
          }

          provider_times_first_open += service_duration.minutes

          block_hour[:status] = status
          block_hour[:hour] = hour

          available_time << block_hour
        end
      end

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
                if !service.group_service || service.id != booking.service_id
                  status = 'occupied'
                elsif service.group_service && service.id == booking.service_id && ServiceProvider.find(params[:provider]).bookings.where(:service_id => service.id, :start => booking.start).count >= service.capacity
                  status = 'occupied'
                end
              end
            end
            if service.resources.count > 0
              service.resources.each do |resource|
                if !local.resource_locations.pluck(:resource_id).include?(resource.id)
                  status = 'occupied'
                end
                used_resource = 0
                group_services = []
                local.bookings.each do |location_booking|
                  booking_start = DateTime.parse(location_booking.start.to_s)
                  booking_end = DateTime.parse(location_booking.end.to_s)
                  if location_booking != cancelled_id && (booking_start - end_time_block) * (start_time_block - booking_end) > 0
                    if location_booking.service.resources.include?(resource)
                      if !location_booking.service.group_service
                        used_resource += 1
                      else
                        if location_booking.service != service || location_booking.service_provider != booking.service_provider
                          group_services.push(location_booking.service_provider.id)
                        end
                      end   
                    end
                  end
                end
                if ResourceLocation.where(resource_id: resource.id, location_id: local.id).first && group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: local.id).first.quantity
                  status = 'occupied'
                end
              end
            end
          end

          block_hour[:status] = status
          block_hour[:hour] = hour

          available_time << block_hour
        end

        # => Empty Blocks
        if ($i + 1) < $length
          next_provider_time = provider_times[$i + 1]
          next_provider_time_open = next_provider_time.open

          while (provider_time_open <=> next_provider_time_open) < 0 do
            block_hour = Hash.new

            status = 'empty'
            hour = {
              :start => '',
              :end => ''
            }

            provider_time_open += service_duration.minutes

            block_hour[:status] = status
            block_hour[:hour] = hour

            available_time << block_hour
          end
        end

        $i += 1
      end

      # Empty Blocks after
      if provider_times.length > 0
        provider_times_final_close = provider_times_final.close
        provider_time_close = provider_times[$length - 1].close
        while (provider_time_close <=> provider_times_final_close) < 0 do
          block_hour = Hash.new

          status = 'empty'
          hour = {
            :start => '',
            :end => ''
          }

          provider_time_close += service_duration.minutes

          block_hour[:status] = status
          block_hour[:hour] = hour

          available_time << block_hour
        end
      end

      @week_blocks[date] = available_time
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
      params.require(:location).permit(:name, :address, :phone, :outcall, :longitude, :latitude, :company_id, :district_id, district_ids: [], location_times_attributes: [:id, :open, :close, :day_id, :location_id])
    end
end
