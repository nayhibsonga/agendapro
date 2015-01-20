class DealsController < ApplicationController
  before_action :set_deal, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"

  # GET /deals
  # GET /deals.json
  def index
    @deals = Deal.all
  end

  # GET /deals/1
  # GET /deals/1.json
  def show
  end

  # GET /deals/new
  def new
    @deal = Deal.new
  end

  # GET /deals/1/edit
  def edit
  end

  # POST /deals
  # POST /deals.json
  def create
    @deal = Deal.new(deal_params)

    respond_to do |format|
      if @deal.save
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting), notice: 'Convenio agregado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @deal }
      else
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting), notice: 'No se pudo agregar el convenio. Por favor inténtalo nuevamente.' }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deals/1
  # PATCH/PUT /deals/1.json
  def update
    respond_to do |format|
      if @deal.update(deal_params)
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting), notice: 'Convenio agregado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @deal }
      else
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting), notice: 'No se pudo agregar el convenio. Por favor inténtalo nuevamente.' }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deals/1
  # DELETE /deals/1.json
  def destroy
    @deal.destroy
    respond_to do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting), notice: 'Convenio eliminado exitosamente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deal
      @deal = Deal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def deal_params
      params.require(:deal).permit(:code, :quantity, :active, :constraint_option, :constraint_quantity, :company_id)
    end
end
