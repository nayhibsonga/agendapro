class DistrictsController < ApplicationController
  before_action :set_district, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :verify_is_super_admin
  layout "admin"
  load_and_authorize_resource

  # GET /districts
  # GET /districts.json
  def index
    @districts = District.all
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
