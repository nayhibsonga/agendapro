class LocationTimesController < ApplicationController
  before_action :set_location_time, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:scheduleLocal]

  # GET /location_times
  # GET /location_times.json
  def index
    @location_times = LocationTime.all
  end

  # GET /location_times/1
  # GET /location_times/1.json
  def show
  end

  # GET /location_times/new
  def new
    @location_time = LocationTime.new
  end

  # GET /location_times/1/edit
  def edit
  end

  # POST /location_times
  # POST /location_times.json
  def create
    @location_time = LocationTime.new(location_time_params)

    respond_to do |format|
      if @location_time.save
        format.html { redirect_to @location_time, notice: 'Location time was successfully created.' }
        format.json { render action: 'show', status: :created, location: @location_time }
      else
        format.html { render action: 'new' }
        format.json { render json: @location_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /location_times/1
  # PATCH/PUT /location_times/1.json
  def update
    respond_to do |format|
      if @location_time.update(location_time_params)
        format.html { redirect_to @location_time, notice: 'Location time was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @location_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /location_times/1
  # DELETE /location_times/1.json
  def destroy
    @location_time.destroy
    respond_to do |format|
      format.html { redirect_to location_times_url }
      format.json { head :no_content }
    end
  end

  def scheduleLocal
    lunes = LocationTime.where("location_id = ? AND day_id = ?", params[:local], 1).order(open: :asc)
    martes = LocationTime.where("location_id = ? AND day_id = ?", params[:local], 2).order(open: :asc)
    miercoles = LocationTime.where("location_id = ? AND day_id = ?", params[:local], 3).order(open: :asc)
    jueves = LocationTime.where("location_id = ? AND day_id = ?", params[:local], 4).order(open: :asc)
    viernes = LocationTime.where("location_id = ? AND day_id = ?", params[:local], 5).order(open: :asc)
    sabado = LocationTime.where("location_id = ? AND day_id = ?", params[:local], 6).order(open: :asc)
    domingo = LocationTime.where("location_id = ? AND day_id = ?", params[:local], 7).order(open: :asc)

    render :json => {
      :lunes => lunes,
      :martes => martes,
      :miercoles => miercoles,
      :jueves => jueves,
      :viernes => viernes,
      :sabado => sabado,
      :domingo => domingo
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location_time
      @location_time = LocationTime.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_time_params
      params.require(:location_time).permit(:open, :close, :location_id, :day_id)
    end
end
