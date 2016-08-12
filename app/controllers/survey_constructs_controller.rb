class SurveyConstructsController < ApplicationController
  before_action :set_survey_construct, only: [:show, :edit, :update, :destroy]
  before_action :survey_question_params, only: [:create,:update]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  def index
    @survey_constructs = SurveyConstruct.all
  end

  def show

  end

  def new
    @survey_construct = SurveyConstruct.new
    @survey_construct.company_id = current_user.company_id
    @survey_question = SurveyQuestion.new
  end

  def edit
  end

  def create
    @survey_construct = SurveyConstruct.new(survey_construct_params)
    @survey_construct.company_id = current_user.company_id
    @survey_construct.save
    @question.zip(@description,@type).each do |question, description, type|
      @survey_question = @survey_construct.survey_questions.new(question:question,description:description, type_question: type)
      @survey_question.save
    end
    respond_to do |format|
      format.html {redirect_to survey_constructs_path, notice: "Tu encuesta se ha creado."}
    end
  end

  def update
    @survey_construct.update(survey_construct_params)
    @i = 0;
    @question.zip(@description,@type).each do |question, description, type|
      @survey_question[@i].question = question
      @survey_question[@i].description = description
      @survey_question[@i].type_question = type
      @survey_question[@i].save
      @i = @i + 1;
    end
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
      @survey_question = SurveyQuestion.all.where(survey_construct_id: @survey_construct)
    end

    def survey_construct_params
      params.require(:survey_construct).permit(:name, survey_question: [:question,:description,:type_question])
    end

    def survey_question_params
      @question = params.require(:survey_question).require(:question)
      @description = params.require(:survey_question).require(:description)
      @type = params.require(:survey_question).require(:type_question)
    end
end
