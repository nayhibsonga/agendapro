class DistrictsController < ApplicationController
  before_action :set_district, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:get_districts, :get_district, :get_direction, :get_district_by_name]
  before_action :verify_is_super_admin, except: [:get_districts, :get_district, :get_direction, :get_district_by_name, :city_districs]
  layout "admin"
  load_and_authorize_resource

  # GET /districts
  # GET /districts.json
  def index
    @districts = District.all.order(:name)
  end

  # GET /districts/1
  # GET /districts/1.json
  def show
  end

  # GET /districts/new
  def new
    @district = District.new
  end

  # GET /districts/1/edit
  def edit
  end

  # POST /districts
  # POST /districts.json
  def create
    @district = District.new(district_params)

    respond_to do |format|
      if @district.save
        format.html { redirect_to @district, notice: 'La comuna fue creada exitosamente.' }
        format.json { render action: 'show', status: :created, location: @district }
      else
        format.html { render action: 'new' }
        format.json { render json: @district.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /districts/1
  # PATCH/PUT /districts/1.json
  def update
    respond_to do |format|
      if @district.update(district_params)
        format.html { redirect_to @district, notice: 'La comuna fue actualizada exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @district.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /districts/1
  # DELETE /districts/1.json
  def destroy
    @district.destroy
    respond_to do |format|
      format.html { redirect_to districts_url }
      format.json { head :no_content }
    end
  end

  def get_districts
    districts = District.where('name ~* ?', params[:term])

    @districts_array = Array.new
    label = 
    districts.each do |district|
      label = district.name + ', ' + district.city.name + ', ' + district.city.region.name + ', ' + district.city.region.country.name
      @districts_array.push({:label => label, :value => district.name})
    end

    render :json => @districts_array
  end

  def get_district
    @district = District.find(params[:id])
    render :json => @district
  end

  def get_direction
    district = District.find(params[:id])
    city = district.city
    region = city.region
    country = region.country
    @geolocation = [district.name + ', ' + city.name + ', ' + region.name + ', ' + country.name]

    render :json => @geolocation
  end

  def get_district_by_name
    @district = District.find_by(name: params[:name])
    render :json => @district
  end

  def city_districs
    @districts = District.where(:city_id => params[:city_id])
    render :json => @districts
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_district
      @district = District.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def district_params
      params.require(:district).permit(:name, :city_id)
    end
end
