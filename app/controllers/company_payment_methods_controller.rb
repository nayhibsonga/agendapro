class CompanyPaymentMethodsController < ApplicationController
  before_action :set_company_payment_method, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @company_payment_methods = CompanyPaymentMethod.all
    respond_with(@company_payment_methods)
  end

  def show
    respond_with(@company_payment_method)
  end

  def new
    @company_payment_method = CompanyPaymentMethod.new
    respond_with(@company_payment_method)
  end

  def edit
  end

  def create
    @company_payment_method = CompanyPaymentMethod.new(company_payment_method_params)
    flash[:notice] = "Medio de Pago creado." if @company_payment_method.save
    respond_with(@company_payment_method) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def update
    flash[:notice] = "Medio de Pago editado." if @company_payment_method.update(company_payment_method_params)
    respond_with(@company_payment_method) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def destroy
    flash[:notice] = "Medio de Pago eliminado." if @company_payment_method.destroy
    respond_with(@company_payment_method) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def activate
    @company_payment_method.active = true
    flash[:notice] = "Medio de Pago activado." if @company_payment_method.save
    respond_with(@company_payment_method) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def deactivate
    @company_payment_method.active = false
    flash[:notice] = "Medio de Pago desactivado." if @company_payment_method.save
    respond_with(@company_payment_method) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  private
    def set_company_payment_method
      @company_payment_method = CompanyPaymentMethod.find(params[:id])
    end

    def company_payment_method_params
      params.require(:company_payment_method).permit(:name, :company_id, :active, :number_required)
    end
end
