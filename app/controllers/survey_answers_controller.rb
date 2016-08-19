class SurveyAnswersController < ApplicationController
  before_action :set_survey_answer, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @survey_answers = SurveyAnswer.all
    respond_with(@survey_answers)
  end

  def show
    respond_with(@survey_answer)
  end

  def new
    @survey_answer = SurveyAnswer.new
    respond_with(@survey_answer)
  end

  def edit
  end

  def create
    @survey_answer = SurveyAnswer.new(survey_answer_params)
    @survey_answer.save
    respond_with(@survey_answer)
  end

  def update
    @survey_answer.update(survey_answer_params)
    respond_with(@survey_answer)
  end

  def destroy
    @survey_answer.destroy
    respond_with(@survey_answer)
  end

  private
    def set_survey_answer
      @survey_answer = SurveyAnswer.find(params[:id])
    end

    def survey_answer_params
      params[:survey_answer]
    end
end
