class SurveyQuestionConstructsController < ApplicationController
  before_action :set_survey_question_construct, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @survey_question_constructs = SurveyQuestionConstruct.all
    respond_with(@survey_question_constructs)
  end

  def show
    respond_with(@survey_question_construct)
  end

  def new
    @survey_question_construct = SurveyQuestionConstruct.new
    respond_with(@survey_question_construct)
  end

  def edit
  end

  def create
    @survey_question_construct = SurveyQuestionConstruct.new(survey_question_construct_params)
    @survey_question_construct.save
    respond_with(@survey_question_construct)
  end

  def update
    @survey_question_construct.update(survey_question_construct_params)
    respond_with(@survey_question_construct)
  end

  def destroy
    @survey_question_construct.destroy
    respond_with(@survey_question_construct)
  end

  private
    def set_survey_question_construct
      @survey_question_construct = SurveyQuestionConstruct.find(params[:id])
    end

    def survey_question_construct_params
      params.require(:survey_question_construct).permit(:survey_question_id, :survey_construct_id)
    end
end
