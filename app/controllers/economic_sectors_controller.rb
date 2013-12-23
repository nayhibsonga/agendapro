class EconomicSectorsController < ApplicationController
  before_action :set_economic_sector, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /economic_sectors
  # GET /economic_sectors.json
  def index
    @economic_sectors = EconomicSector.all
  end

  # GET /economic_sectors/1
  # GET /economic_sectors/1.json
  def show
  end

  # GET /economic_sectors/new
  def new
    @economic_sector = EconomicSector.new
  end

  # GET /economic_sectors/1/edit
  def edit
  end

  # POST /economic_sectors
  # POST /economic_sectors.json
  def create
    @economic_sector = EconomicSector.new(economic_sector_params)

    respond_to do |format|
      if @economic_sector.save
        format.html { redirect_to @economic_sector, notice: 'Sector Económico fue creado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @economic_sector }
      else
        format.html { render action: 'new' }
        format.json { render json: @economic_sector.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /economic_sectors/1
  # PATCH/PUT /economic_sectors/1.json
  def update
    respond_to do |format|
      if @economic_sector.update(economic_sector_params)
        format.html { redirect_to @economic_sector, notice: 'Sector Económico fue actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @economic_sector.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /economic_sectors/1
  # DELETE /economic_sectors/1.json
  def destroy
    @economic_sector.destroy
    respond_to do |format|
      format.html { redirect_to economic_sectors_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_economic_sector
      @economic_sector = EconomicSector.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def economic_sector_params
      params.require(:economic_sector).permit(:name)
    end
end
