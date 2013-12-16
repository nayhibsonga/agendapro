class PaymentStatusesController < ApplicationController
  before_action :set_payment_status, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :verify_is_super_admin

  # GET /payment_statuses
  # GET /payment_statuses.json
  def index
    @payment_statuses = PaymentStatus.all
  end

  # GET /payment_statuses/1
  # GET /payment_statuses/1.json
  def show
  end

  # GET /payment_statuses/new
  def new
    @payment_status = PaymentStatus.new
  end

  # GET /payment_statuses/1/edit
  def edit
  end

  # POST /payment_statuses
  # POST /payment_statuses.json
  def create
    @payment_status = PaymentStatus.new(payment_status_params)

    respond_to do |format|
      if @payment_status.save
        format.html { redirect_to @payment_status, notice: 'Estado de pago fue creado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @payment_status }
      else
        format.html { render action: 'new' }
        format.json { render json: @payment_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_statuses/1
  # PATCH/PUT /payment_statuses/1.json
  def update
    respond_to do |format|
      if @payment_status.update(payment_status_params)
        format.html { redirect_to @payment_status, notice: 'Estado de pago fue actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @payment_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_statuses/1
  # DELETE /payment_statuses/1.json
  def destroy
    @payment_status.destroy
    respond_to do |format|
      format.html { redirect_to payment_statuses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_status
      @payment_status = PaymentStatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_status_params
      params.require(:payment_status).permit(:name, :description)
    end
end
