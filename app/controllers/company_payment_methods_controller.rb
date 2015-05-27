class CompanyPaymentMethodsController < ApplicationController
  before_action :set_company_payment_method, only: [:show, :edit, :update, :destroy]

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
    @company_payment_method.save
    respond_with(@company_payment_method)
  end

  def update
    @company_payment_method.update(company_payment_method_params)
    respond_with(@company_payment_method)
  end

  def destroy
    @company_payment_method.destroy
    respond_with(@company_payment_method)
  end

  private
    def set_company_payment_method
      @company_payment_method = CompanyPaymentMethod.find(params[:id])
    end

    def company_payment_method_params
      params.require(:company_payment_method).permit(:name, :company_id)
    end
end
