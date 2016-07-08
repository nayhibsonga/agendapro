class EmployeeCodesController < ApplicationController
  before_action :set_employee_code, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @employee_codes = EmployeeCode.all
    respond_with(@employee_codes)
  end

  def show
    respond_with(@employee_code)
  end

  def new
    @employee_code = EmployeeCode.new
    respond_with(@employee_code)
  end

  def edit
  end

  def create
    @employee_code = EmployeeCode.new(employee_code_params)
    flash[:success] = "Código creado." if @employee_code.save
    respond_with(@employee_code) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'employee-codes') }
    end
  end

  def update
    flash[:success] = "Código editado." if @employee_code.update(employee_code_params)
    respond_with(@employee_code) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'employee-codes') }
    end
  end

  def destroy
    flash[:success] = "Código eliminado." if @employee_code.destroy
    respond_with(@employee_code) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'employee-codes') }
    end
  end

  def activate
    @employee_code.active = true
    flash[:success] = "Código activado." if @employee_code.save
    respond_with(@employee_code) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'employee-codes') }
    end
  end

  def deactivate
    @employee_code.active = false
    flash[:success] = "Código desactivado." if @employee_code.save
    respond_with(@employee_code) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'employee-codes') }
    end
  end

  #Get a cashier by code
  def get_by_code

    employee_code = EmployeeCode.where(code: params[:employee_code_code], company_id: current_user.company_id, :active => true, cashier: true).first

    return_array = []
    if employee_code.nil?
      return_array << "error"
    else
      return_array << employee_code
    end

    render :json => return_array

  end

  def check_staff_code
    @employee_code = EmployeeCode.where(code: params[:booking_employee_code], company_id: current_user.company_id, active: true, staff: true).first
    render :json => !@employee_code.nil?
  end

  private
    def set_employee_code
      @employee_code = EmployeeCode.find(params[:id])
    end

    def employee_code_params
      params.require(:employee_code).permit(:name, :code, :company_id, :active, :staff, :cashier)
    end
end
