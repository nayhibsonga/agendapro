class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:view_plans]
  before_action :quick_add, except: [:view_plans, :select_plan]
  before_action :verify_is_super_admin, except: [:index, :view_plans, :select_plan]
  layout "admin", except: [:view_plans]
  load_and_authorize_resource

  # GET /plans
  # GET /plans.json
  def index
    @plans = Plan.all
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
  end

  # GET /plans/new
  def new
    @plan = Plan.new
  end

  # GET /plans/1/edit
  def edit
  end

  # POST /plans
  # POST /plans.json
  def create
    @plan = Plan.new(plan_params)

    respond_to do |format|
      if @plan.save
        format.html { redirect_to @plan, notice: 'El plan fue creado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @plan }
      else
        format.html { render action: 'new' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to @plan, notice: 'El plan fue actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    @plan.destroy
    respond_to do |format|
      format.html { redirect_to plans_url }
      format.json { head :no_content }
    end
  end

  def select_plan
    @due_payment = false
    @plans = Plan.where(:custom => false)
    @company = Company.find(current_user.company_id)
    @company.billing_info ? @billing_info = @company.billing_info : @billing_info = BillingInfo.new
    @price = @company.plan.price
    @sales_tax = NumericParameter.find_by_name("sales_tax").value
    @month_discount_4 = NumericParameter.find_by_name("4_month_discount").value
    @month_discount_6 = NumericParameter.find_by_name("6_month_discount").value
    @month_discount_9 = NumericParameter.find_by_name("9_month_discount").value
    @month_discount_12 = NumericParameter.find_by_name("12_month_discount").value

    if params[:plan_id] && @plans.pluck(:id).include?(params[:plan_id].to_i)
      @company.plan_id = params[:plan_id]
      if @company.save
        redirect_to select_plan_path, notice: "El plan nuevo plan fue seleccionado exitosamente."
      else
        redirect_to select_plan_path, notice: "El plan no pudo ser cambiado. Tienes más locales/proveedores activos que lo que permite el plan, o no tienes los permisos necesarios para hacer este cambio."
      end
    end

  end

  def view_plans
    @plans = Plan.where(custom: false)
    render layout: "home"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_params
      params.require(:plan).permit(:name, :locations, :service_providers, :custom)
    end
end
