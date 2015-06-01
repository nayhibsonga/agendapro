class PaymentMethodTypesController < ApplicationController
  before_action :set_payment_method_type, only: [:show, :edit, :update, :destroy]
  before_action :verify_is_super_admin
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @payment_method_types = PaymentMethodType.all
    respond_with(@payment_method_types)
  end

  def show
    respond_with(@payment_method_type)
  end

  def new
    @payment_method_type = PaymentMethodType.new
    respond_with(@payment_method_type)
  end

  def edit
  end

  def create
    @payment_method_type = PaymentMethodType.new(payment_method_type_params)
    @payment_method_type.save
    respond_with(@payment_method_type)
  end

  def update
    @payment_method_type.update(payment_method_type_params)
    respond_with(@payment_method_type)
  end

  def destroy
    @payment_method_type.destroy
    respond_with(@payment_method_type)
  end

  private
    def set_payment_method_type
      @payment_method_type = PaymentMethodType.find(params[:id])
    end

    def payment_method_type_params
      params.require(:payment_method_type).permit(:name)
    end
end
