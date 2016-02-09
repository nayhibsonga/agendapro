class CompanyPlanSettingsController < ApplicationController
  before_action :set_company_plan_setting, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  respond_to :html

  def index
    @company_plan_settings = CompanyPlanSetting.all
    respond_with(@company_plan_settings)
  end

  def show
    respond_with(@company_plan_setting)
  end

  def new
    @company_plan_setting = CompanyPlanSetting.new
    respond_with(@company_plan_setting)
  end

  def edit
  end

  def create
    @company_plan_setting = CompanyPlanSetting.new(company_plan_setting_params)
    @company_plan_setting.save
    respond_with(@company_plan_setting)
  end

  def update
    @company_plan_setting.update(company_plan_setting_params)
    respond_with(@company_plan_setting)
  end

  def destroy
    @company_plan_setting.destroy
    respond_with(@company_plan_setting)
  end

  private
    def set_company_plan_setting
      @company_plan_setting = CompanyPlanSetting.find(params[:id])
    end

    def company_plan_setting_params
      params.require(:company_plan_setting).permit(:company_id, :base_price, :locations_multiplier)
    end
end
