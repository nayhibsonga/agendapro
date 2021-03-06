class ReceiptTypesController < ApplicationController
  before_action :set_receipt_type, only: [:show, :edit, :update, :destroy]
  before_action :verify_is_super_admin
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @receipt_types = ReceiptType.all
    respond_with(@receipt_types)
  end

  def show
    respond_with(@receipt_type)
  end

  def new
    @receipt_type = ReceiptType.new
    respond_with(@receipt_type)
  end

  def edit
  end

  def create
    @receipt_type = ReceiptType.new(receipt_type_params)
    flash[:success] = "Tipo de Comprobante de Pago creado." if @receipt_type.save
    respond_with(@receipt_type) do |format|
      format.html { redirect_to receipt_types_path }
    end
  end

  def update
    flash[:success] = "Tipo de Comprobante de Pago editado." if @receipt_type.update(receipt_type_params)
    respond_with(@receipt_type) do |format|
      format.html { redirect_to receipt_types_path }
    end
  end

  def destroy
    @receipt_type.destroy
    respond_with(@receipt_type)
  end

  private
    def set_receipt_type
      @receipt_type = ReceiptType.find(params[:id])
    end

    def receipt_type_params
      params.require(:receipt_type).permit(:name)
    end
end
