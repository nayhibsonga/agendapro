class CompanySettingsController < ApplicationController
  before_action :set_company_setting, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  load_and_authorize_resource
  layout "admin"


  # GET /company_settings
  # GET /company_settings.json
  def index
    @company_settings = CompanySetting.all
  end

  # GET /company_settings/1
  # GET /company_settings/1.json
  def show
  end

  # GET /company_settings/new
  def new
    @company_setting = CompanySetting.new
    @company_setting.company_id = current_user.company_id
    #@company_setting.build_online_cancelation_policy
  end

  # GET /company_settings/1/edit
  def edit
    @company = Company.find(current_user.company_id)
    @banks = Bank.all
    @emails = current_user.company.company_from_email
    @company_from_email = CompanyFromEmail.new
    @staff_codes = current_user.company.staff_codes
    @staff_code = StaffCode.new
    @deals = current_user.company.deals
    @deal = Deal.new
    @company_setting = @company.company_setting
    @online_cancelation_policy = OnlineCancelationPolicy.new
    if(!@company_setting.online_cancelation_policy.nil?)
      @online_cancelation_policy = @company_setting.online_cancelation_policy
    else
      @online_cancelation_policy = @company_setting.build_online_cancelation_policy
    end
    @web_address = Company.find(current_user.company_id).web_address

  end

  # POST /company_settings
  # POST /company_settings.json
  def create
    @company_setting = CompanySetting.new(company_setting_params)
    @company_setting.company_id = current_user.company_id
    

    respond_to do |format|
      if @company_setting.save
        format.html { redirect_to @company_setting, notice: 'Company setting was successfully created.' }
        format.json { render action: 'show', status: :created, location: @company_setting }
      else
        format.html { render action: 'new' }
        format.json { render json: @company_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /company_settings/1
  # PATCH/PUT /company_settings/1.json
  def update
    respond_to do |format|
      if @company_setting.update(company_setting_params)
        #if(params[:company_setting][:online_cancelation_policy])
          #@company_setting.online_cancelation_policy.update(params[:company_setting][:online_cancelation_policy])
        #end
        format.html { redirect_to edit_company_setting_path(@company_setting), notice: 'Configuración actualizada exitosamente.' }
        format.json { head :no_content }
      else
        format.html {
          errors = ''
          @company_setting.errors.full_messages.each do |error|
            errors += error + ' '
          end
          flash[:alert] = errors
          @company = Company.find(current_user.company_id)
          @emails = current_user.company.company_from_email
          @company_from_email = CompanyFromEmail.new
          @staff_codes = current_user.company.staff_codes
          @staff_code = StaffCode.new
          @deals = current_user.company.deals
          @deal = Deal.new
          @company_setting = @company.company_setting
          @web_address = Company.find(current_user.company_id).web_address
          redirect_to edit_company_setting_path(@company_setting)
        }
        format.json { render json: @company_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /company_settings/1
  # DELETE /company_settings/1.json
  def destroy
    @company_setting.destroy
    respond_to do |format|
      format.html { redirect_to company_settings_url }
      format.json { head :no_content }
    end
  end

  def time_booking_edit
    @company_setting = CompanySetting.find_by(:company_id => params[:company])
  end

  def minisite
    @company_setting = CompanySetting.find_by(:company_id => params[:company])
  end


  def update_payment

    

  end


  def delete_facebook_pages
    @facebook_pages = FacebookPage.where(company_id: current_user.company_id)
    @facebook_pages.delete_all
    @company_setting =  CompanySetting.find(params[:id])
    respond_to do |format|
      format.html { redirect_to edit_company_setting_path(@company_setting), notice: 'Configuración de Facebook desactivada exitosamente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_setting
      @company_setting = CompanySetting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_setting_params
      params.require(:company_setting).permit(:email, :sms, :signature, :company_id, :before_booking, :after_booking, :before_edit_booking, :activate_workflow, :activate_search, :client_exclusive, :provider_preference, :calendar_duration, :extended_schedule_bool, :extended_min_hour, :extended_max_hour, :schedule_overcapacity, :provider_overcapacity, :resource_overcapacity, :booking_confirmation_time, :page_id, :booking_history, :staff_code, :booking_configuration_email, :max_changes, :deal_name, :deal_activate, :deal_overcharge, :deal_exclusive, :deal_quantity, :deal_constraint_option, :deal_constraint_quantity, :deal_identification_number, :deal_required, :allows_online_payment, :bank_id, :account_number, :company_rut, :account_name, :account_type, :allows_optimization, :activate_notes, online_cancelation_policy_attributes: [:cancelable, :cancel_max, :cancel_unit, :min_hours, :modifiable, :modification_max, :modification_unit], promo_time_attributes: [:morning_start, :morning_end, :afternoon_start, :afternoon_end, :night_start, :night_end, :morning_default, :afternoon_default, :night_default, :active])
    end
end
