class NumericParametersController < ApplicationController
  before_action :set_numeric_parameter, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :verify_is_super_admin
  layout "admin"
  load_and_authorize_resource

  # GET /numeric_parameters
  # GET /numeric_parameters.json
  def index
    @numeric_parameters = NumericParameter.all
  end

  # GET /numeric_parameters/1
  # GET /numeric_parameters/1.json
  def show
  end

  # GET /numeric_parameters/new
  def new
    @numeric_parameter = NumericParameter.new
  end

  # GET /numeric_parameters/1/edit
  def edit
  end

  # POST /numeric_parameters
  # POST /numeric_parameters.json
  def create
    @numeric_parameter = NumericParameter.new(numeric_parameter_params)

    respond_to do |format|
      if @numeric_parameter.save
        format.html { redirect_to @numeric_parameter, notice: 'Numeric parameter was successfully created.' }
        format.json { render action: 'show', status: :created, location: @numeric_parameter }
      else
        format.html { render action: 'new' }
        format.json { render json: @numeric_parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /numeric_parameters/1
  # PATCH/PUT /numeric_parameters/1.json
  def update
    respond_to do |format|
      if @numeric_parameter.update(numeric_parameter_params)
        format.html { redirect_to @numeric_parameter, notice: 'Numeric parameter was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @numeric_parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /numeric_parameters/1
  # DELETE /numeric_parameters/1.json
  def destroy
    @numeric_parameter.destroy
    respond_to do |format|
      format.html { redirect_to numeric_parameters_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_numeric_parameter
      @numeric_parameter = NumericParameter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def numeric_parameter_params
      params.require(:numeric_parameter).permit(:name, :value)
    end
end
