class StaffCodesController < ApplicationController
  before_action :set_staff_code, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"
  # load_and_authorize_resource

  # GET /staff_codes
  # GET /staff_codes.json
  def index
    @staff_codes = StaffCode.all
  end

  # GET /staff_codes/1
  # GET /staff_codes/1.json
  def show
  end

  # GET /staff_codes/new
  def new
    @staff_code = StaffCode.new
  end

  # GET /staff_codes/1/edit
  def edit
  end

  # POST /staff_codes
  # POST /staff_codes.json
  def create
    @staff_code = StaffCode.new(staff_code_params)

    respond_to do |format|
      if @staff_code.save
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'calendar'), notice: 'Código de empleado agregado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @staff_code }
      else
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'calendar'), notice: 'No se pudo agregar el código. Por favor inténtalo nuevamente.' }
        format.json { render json: @staff_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staff_codes/1
  # PATCH/PUT /staff_codes/1.json
  def update
    respond_to do |format|
      if @staff_code.update(staff_code_params)
        format.html { redirect_to @staff_code, notice: 'Staff code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @staff_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_codes/1
  # DELETE /staff_codes/1.json
  def destroy
    @staff_code.destroy
    respond_to do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'calendar'), notice: 'Código de empleado eliminado exitosamente.'}
      format.json { head :no_content }
    end
  end

  def check_staff_code
    @staff_code = StaffCode.where(code: params[:booking_staff_code], company_id: current_user.company_id).first
    render :json => !@staff_code.nil?
  end

  def get_staff_by_code

    staff_code = StaffCode.where(code: params[:payment_staff_code], company_id: current_user.company_id).first

    return_array = []
    if staff_code.nil?
      return_array << "error"
    else
      return_array << staff_code
    end

    render :json => return_array
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff_code
      @staff_code = StaffCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def staff_code_params
      params.require(:staff_code).permit(:staff, :code, :company_id)
    end
end
