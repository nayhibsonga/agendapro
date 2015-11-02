class CashiersController < ApplicationController
  before_action :set_cashier, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @cashiers = Cashier.all
    respond_with(@cashiers)
  end

  def show
    respond_with(@cashier)
  end

  def new
    @cashier = Cashier.new
    respond_with(@cashier)
  end

  def edit
  end

  def create
    @cashier = Cashier.new(cashier_params)
    flash[:notice] = "Cajero creado." if @cashier.save
    respond_with(@cashier) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def update
    flash[:notice] = "Cajero editado." if @cashier.update(cashier_params)
    respond_with(@cashier) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def destroy
    flash[:notice] = "Cajero eliminado." if @cashier.destroy
    respond_with(@cashier) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def activate
    @cashier.active = true
    flash[:notice] = "Cajero activado." if @cashier.save
    respond_with(@cashier) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def deactivate
    @cashier.active = false
    flash[:notice] = "Cajero desactivado." if @cashier.save
    respond_with(@cashier) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'cashier') }
    end
  end

  def get_by_code

    cashier = Cashier.where(code: params[:payment_cashier_code], company_id: current_user.company_id, :active => true).first

    return_array = []
    if cashier.nil?
      return_array << "error"
    else
      return_array << cashier
    end

    render :json => return_array

  end

  private
    def set_cashier
      @cashier = Cashier.find(params[:id])
    end

    def cashier_params
      params.require(:cashier).permit(:company_id, :name, :code, :active)
    end
end
