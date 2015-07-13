class PaymentMethodsController < ApplicationController
  before_action :set_payment_method, only: [:show, :edit, :update, :destroy]
  before_action :verify_is_super_admin
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @payment_methods = PaymentMethod.all
    respond_with(@payment_methods)
  end

  def show
    respond_with(@payment_method)
  end

  def new
    @payment_method = PaymentMethod.new
    respond_with(@payment_method)
  end

  def edit
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params)
    flash[:notice] = "Medio de Pago creado." if @payment_method.save
    respond_with(@payment_method) do |format|
      format.html { redirect_to payment_methods_path }
    end
  end

  def update
    flash[:notice] = "Medio de Pago editado." if @payment_method.update(payment_method_params)
    respond_with(@payment_method) do |format|
      format.html { redirect_to payment_methods_path }
    end
  end

  def destroy
    @payment_method.destroy
    respond_with(@payment_method)
  end

  private
    def set_payment_method
      @payment_method = PaymentMethod.find(params[:id])
    end

    def payment_method_params
      params.require(:payment_method).permit(:name)
    end
end
