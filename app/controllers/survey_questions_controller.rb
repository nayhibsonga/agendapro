class SurveyQuestionsController < ApplicationController
  before_action :set_survey_question, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  def index
    @survey_questions = SurveyQuestion.all
  end

  def show
    respond_with(@survey_question)
  end

  def new
    @survey_question = SurveyQuestion.new
    respond_with(@survey_question)
  end

  def edit
  end

  def create
    @survey_question = SurveyQuestion.new(survey_question_params)
    @survey_question.save
    respond_with(@survey_question)
  end

  def update
    @survey_question.update(survey_question_params)
    respond_with(@survey_question)
  end

  def destroy
    @survey_question.destroy
    respond_with(@survey_question)
  end

  private
    def set_survey_question
      @survey_question = SurveyQuestion.find(params[:id])
    end

    def survey_question_params
      params[:survey_question]
    end
end
