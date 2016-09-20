class EconomicSectorsDictionariesController < ApplicationController
  before_action :set_economic_sectors_dictionary, only: [:show, :edit, :update, :destroy]

  # GET /economic_sectors_dictionaries
  # GET /economic_sectors_dictionaries.json
  def index
    @economic_sectors_dictionaries = EconomicSectorsDictionary.all
  end

  # GET /economic_sectors_dictionaries/1
  # GET /economic_sectors_dictionaries/1.json
  def show
  end

  # GET /economic_sectors_dictionaries/new
  def new
    @economic_sectors_dictionary = EconomicSectorsDictionary.new
  end

  # GET /economic_sectors_dictionaries/1/edit
  def edit
  end

  # POST /economic_sectors_dictionaries
  # POST /economic_sectors_dictionaries.json
  def create
    @economic_sectors_dictionary = EconomicSectorsDictionary.new(economic_sectors_dictionary_params)

    respond_to do |format|
      if @economic_sectors_dictionary.save
        format.html { redirect_to @economic_sectors_dictionary, notice: 'Economic sectors dictionary was successfully created.' }
        format.json { render action: 'show', status: :created, location: @economic_sectors_dictionary }
      else
        format.html { render action: 'new' }
        format.json { render json: @economic_sectors_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /economic_sectors_dictionaries/1
  # PATCH/PUT /economic_sectors_dictionaries/1.json
  def update
    respond_to do |format|
      if @economic_sectors_dictionary.update(economic_sectors_dictionary_params)
        format.html { redirect_to @economic_sectors_dictionary, notice: 'Economic sectors dictionary was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @economic_sectors_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /economic_sectors_dictionaries/1
  # DELETE /economic_sectors_dictionaries/1.json
  def destroy
    @economic_sectors_dictionary.destroy
    respond_to do |format|
      format.html { redirect_to economic_sectors_dictionaries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_economic_sectors_dictionary
      @economic_sectors_dictionary = EconomicSectorsDictionary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def economic_sectors_dictionary_params
      params.require(:economic_sectors_dictionary).permit(:name, :economic_sector_id)
    end
end
