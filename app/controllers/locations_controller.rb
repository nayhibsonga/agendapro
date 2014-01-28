class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:location_data]
  before_action :quick_add, except: [:location_data]
  load_and_authorize_resource
  layout "admin"

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.where(company_id: current_user.company_id)
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
        format.html { redirect_to @location, notice: 'Local creado satisfactoriamente.' }
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
        format.html { redirect_to @location, notice: 'Local actualizado satisfactoriamente.' }
        format.json { render :json => @location }
      else
        format.html { render action: 'edit' }
        format.json { render :json => { :errors => @location.errors.full_messages }, :status => 422 }
      end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:name, :address, :phone, :longitude, :latitude, :company_id, :district_id, location_times_attributes: [:id, :open, :close, :day_id, :location_id])
    end
end
