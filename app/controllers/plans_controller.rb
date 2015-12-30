class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]
  before_action :constraint_locale, only: [:view_plans]
  before_action :authenticate_user!, except: [:view_plans]
  before_action :quick_add, except: [:view_plans, :select_plan]
  before_action :verify_is_super_admin, except: [:view_plans, :select_plan, :save_billing_wire_transfer]
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
        format.html { redirect_to @plan, notice: 'Plan creado exitosamente.' }
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
        format.html { redirect_to @plan, notice: 'Plan actualizado exitosamente.' }
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
    @company = Company.find(current_user.company_id)
    @plans = Plan.where(:custom => false)
    @company.billing_info ? @billing_info = @company.billing_info : @billing_info = BillingInfo.new
    @company.payment_status == PaymentStatus.find_by_name("Trial") ? @price = Plan.where.not(id: Plan.find_by_name("Gratis").id).where(custom: false).where('locations >= ?', @company.locations.where(active: true).count).where('service_providers >= ?', @company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: @company.country.id).price : @price = @company.plan.plan_countries.find_by(country_id: @company.country.id).price
    @sales_tax = @company.country.sales_tax
    @month_discount_4 = NumericParameter.find_by_name("4_month_discount").value
    @month_discount_6 = NumericParameter.find_by_name("6_month_discount").value
    @month_discount_9 = NumericParameter.find_by_name("9_month_discount").value
    @month_discount_12 = NumericParameter.find_by_name("12_month_discount").value

    @day_number = Time.now.day
    @month_number = Time.now.month
    @month_days = Time.now.days_in_month

    puts "Day number: " + @day_number.to_s
    puts "Month number: " + @month_number.to_s
    puts "Month_days: " + @month_days.to_s

    #@company.months_active_left > 0 ? @plan_1 = (@company.due_amount + @price).round(0) : @plan_1 = ((@company.due_amount + (@month_days - @day_number + 1)*@price/@month_days)).round(0)
    @plan_1 = (@company.due_amount + @price * (1+@sales_tax)).round(0)
    @plan_2 = (@plan_1 + @price*1* (1+@sales_tax)).round(0)
    @plan_3 = (@plan_1 + @price*2* (1+@sales_tax)).round(0)
    @plan_4 = ((@plan_1 + @price*3* (1+@sales_tax))*(1-@month_discount_4)).round(0)
    @plan_6 = ((@plan_1 + @price*5* (1+@sales_tax))*(1-@month_discount_6)).round(0)
    @plan_9 = ((@plan_1 + @price*8* (1+@sales_tax))*(1-@month_discount_9)).round(0)
    @plan_12 = ((@plan_1 + @price*11* (1+@sales_tax))*(1-@month_discount_12)).round(0)

    @billing_wire_transfer = BillingWireTransfer.new
    @billing_wire_transfer.payment_date = DateTime.now - eval(ENV["TIME_ZONE_OFFSET"])
    @billing_wire_transfer.account_name = nil
    @billing_wire_transfer.account_number = nil
    @billing_wire_transfer.bank_id = nil

    #Check for latest billing_wire_transfer to prefill some data

    if BillingWireTransfer.where(company_id: current_user.company_id).count > 0
      last_billing_wire_transfer = BillingWireTransfer.where(company_id: current_user.company_id).order('updated_at desc').first.dup
      @billing_wire_transfer.account_name = last_billing_wire_transfer.account_name
      @billing_wire_transfer.account_number = last_billing_wire_transfer.account_number
      @billing_wire_transfer.bank_id = last_billing_wire_transfer.bank_id
    end

  end

  def save_billing_wire_transfer

    @billing_wire_transfer = BillingWireTransfer.new(payment_date: params[:transfer_datetime].to_datetime, amount: params[:transfer_amount].to_f, account_name: params[:transfer_account_name], account_number: params[:transfer_account_number], approved: false, company_id: current_user.company.id, change_plan: params[:transfer_change_plan], new_plan: params[:transfer_new_plan], bank_id: params[:transfer_bank_id], paid_months: params[:transfer_paid_months])

    if current_user.company.plan_id == Plan.find_by_name("Gratis").id
      downgradeLog = DowngradeLog.where(company_id: current_user.company.id).order('created_at desc').first
      @billing_wire_transfer.new_plan = downgradeLog.plan_id
      @billing_wire_transfer.change_plan = true
    end

    if @billing_wire_transfer.save
      flash[:notice] = 'Transferencia guardada correctamente y en espera de aprobación.'
      CompanyMailer.new_transfer_email(@billing_wire_transfer.id)
      
      redirect_to :action => 'select_plan'
    else
      flash[:alert] = 'Ocurrió un error al tratar de guardar la transferencia.'
      redirect_to :action => 'select_plan'
    end
    
  end


  def generate_company_wire_transfer

    amount = params[:amount].to_i

    company = Company.find(current_user.company_id)
    #company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(custom: false, locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: company.country.id).price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price
    sales_tax = company.country.sales_tax
    day_number = Time.now.day
    month_number = Time.now.month
    month_days = Time.now.days_in_month
    accepted_amounts = [1,2,3,4,6,9,12]

    billing_wire_transfer = BillingWireTransfer.new(payment_date: params[:date], amount: amount, receipt_number: params[:receipt_number], account_name: params[:account_name], account_bank: params[:account_bank], account_number: params[:account_number], approved: false, company_id: company.id, change_plan: false, new_plan: nil, change_plan_amount: 0, new_plan_amount: 0)

    if billing_wire_transfer.save

    else

    end

  end

  def generate_plan_wire_transfer

    amount = params[:amount].to_i

    new_plan = Plan.find(params[:new_plan_id])

    company = Company.find(current_user.company_id)
    
    #company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(custom: false, locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: company.country.id).price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price
    sales_tax = company.country.sales_tax
    day_number = Time.now.day
    month_number = Time.now.month
    month_days = Time.now.days_in_month
    accepted_amounts = [1,2,3,4,6,9,12]

    billing_wire_transfer = BillingWireTransfer.new(payment_date: params[:date], amount: amount, receipt_number: params[:receipt_number], account_name: params[:account_name], account_bank: params[:account_bank], account_number: params[:account_number], approved: false, company_id: company.id, change_plan: true, new_plan: new_plan.id, change_plan_amount: 0, new_plan_amount: 0)

    if billing_wire_transfer.save
      
    else

    end

  end

  def view_plans
    @plans = Plan.where(custom: false).order(:service_providers)
    @country = Country.find_by(locale: I18n.locale.to_s)
    unless @country
      redirect_to landing_path(redirect_params: params.inspect)
    end
    render layout: "home"
  end

  def puntopagos_creations
    @puntopagos_creations = PuntoPagosCreation.all.order(id: :desc).paginate(:page => params[:page], :per_page => 100)
  end

  def puntopagos_confirmations
    @puntopagos_confirmations = PuntoPagosConfirmation.all.order(id: :desc).paginate(:page => params[:page], :per_page => 100)
  end

  def company_cron_logs
    @company_cron_logs = CompanyCronLog.all.order(id: :desc).paginate(:page => params[:page], :per_page => 100)
  end

  def plan_logs
    @plan_logs = PlanLog.all.order(id: :desc).paginate(:page => params[:page], :per_page => 100)
  end

  def billing_logs
    @billing_logs = BillingLog.all.order(id: :desc).paginate(:page => params[:page], :per_page => 100)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_params
      params.require(:plan).permit(:name, :locations, :service_providers, :custom, :special, :monthly_mails, plan_countries_attributes: [:id, :country_id, :price])
    end
end
