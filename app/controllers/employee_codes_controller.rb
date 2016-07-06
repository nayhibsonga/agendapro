class EmployeeCodesController < ApplicationController
  before_action :set_employee_code, only: [:show, :edit, :update, :destroy]

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
    @employee_code.save
    respond_with(@employee_code)
  end

  def update
    @employee_code.update(employee_code_params)
    respond_with(@employee_code)
  end

  def destroy
    @employee_code.destroy
    respond_with(@employee_code)
  end

  private
    def set_employee_code
      @employee_code = EmployeeCode.find(params[:id])
    end

    def employee_code_params
      params.require(:employee_code).permit(:name, :code, :company_id, :active, :staff, :cashier)
    end
end
