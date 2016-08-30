class SurveyConstructsController < ApplicationController
  before_action :set_survey_construct, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource
  respond_to :html
  def index
    @survey_constructs = SurveyConstruct.all
  end

  def show

  end

  def new
    @survey_construct = SurveyConstruct.new
    @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(:order, :name)
    @survey_attributes = SurveyAttribute.new
    survey_questions = @survey_construct.survey_questions.build
    respond_with(@survey_construct)
  end

  def edit
    @service_categories = ServiceCategory.where(company_id: current_user.company_id).order(:order, :name)
  end

  def create
    @survey_construct = SurveyConstruct.new(survey_construct_params)
    @survey_construct.company_id = current_user.company_id
    @survey_construct.save
    @survey_construct.service_survey_constructs.create
    respond_to do |format|
      format.html {redirect_to survey_constructs_path, notice: "Tu encuesta se ha creado."}
    end
  end

  def update
    @survey_construct.assign_attributes(survey_construct_params)
    @survey_construct.save
    respond_to do |format|
      format.html {redirect_to survey_constructs_path, notice: "Encuesta actualizada."}
    end
  end

  def destroy
    @survey_construct.destroy
    respond_to do |format|
      format.html {redirect_to survey_constructs_path, notice: "Encuesta eliminada."}
    end
  end

  private
    def set_survey_construct
      @survey_construct = SurveyConstruct.find(params[:id])
    end

    def survey_construct_params
      params.require(:survey_construct).permit(:name, :service_ids => [], survey_questions_attributes: [:id,:question,:description,:survey_attribute_id,:type_question,:order,:_destroy])
    end

end
