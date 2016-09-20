class SurveyQuestionsController < ApplicationController
  before_action :set_survey_question, only: [:show, :edit, :update, :destroy]
  layout "add_question"
  respond_to :html
  def index
    @survey_questions = SurveyQuestion.all
  end

  def show
    respond_to do |format|
      format.json { render :json => @survey_question }
    end
  end

  def new
    @survey_question = SurveyQuestion.new
    respond_with(@survey_question)
  end

  def edit
    respond_with(@survey_question)
  end

  def create
    @survey_question = SurveyQuestion.new(survey_question_params)
    @survey_question.company_id = current_user.company_id
    @survey_question.type_question = 1
    @survey_question.activate = true
    @survey_question.save
    respond_to do |format|
      format.json { render :json => @survey_question }
    end
  end

  def update
    @survey_question.update(survey_question_params)
    respond_to do |format|
      format.json { render :json => @survey_question }
    end
  end

  def destroy
    @survey_question.update(:activate => false)
    respond_to do |format|
      format.json { render :json => @survey_question }
    end
  end

  private
    def set_survey_question
      @survey_question = SurveyQuestion.find(params[:id])
    end

    def survey_question_params
      params.require(:survey_question).permit(:question, :description, :type_question, :order, :survey_attribute_id, :company_id, :activate)
    end
end
