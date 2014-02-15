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
  end

  # GET /company_settings/1/edit
  def edit
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
        format.html { redirect_to @company_setting, notice: 'Company setting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_setting
      @company_setting = CompanySetting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_setting_params
      params.require(:company_setting).permit(:email, :sms, :signature, :company_id)
    end
end
