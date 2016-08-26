class SurveyQuestionRecommendationsController < ApplicationController
  before_action :set_survey_question_recommendation, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @survey_question_recommendations = SurveyQuestionRecommendation.all
    respond_with(@survey_question_recommendations)
  end

  def show
    respond_with(@survey_question_recommendation)
  end

  def new
    @survey_question_recommendation = SurveyQuestionRecommendation.new
    respond_with(@survey_question_recommendation)
  end

  def edit
  end

  def create
    @survey_question_recommendation = SurveyQuestionRecommendation.new(survey_question_recommendation_params)
    @survey_question_recommendation.save
    respond_with(@survey_question_recommendation)
  end

  def update
    @survey_question_recommendation.update(survey_question_recommendation_params)
    respond_with(@survey_question_recommendation)
  end

  def destroy
    @survey_question_recommendation.destroy
    respond_with(@survey_question_recommendation)
  end

  private
    def set_survey_question_recommendation
      @survey_question_recommendation = SurveyQuestionRecommendation.find(params[:id])
    end

    def survey_question_recommendation_params
      params.require(:survey_question_recommendation).permit(:name, :description)
    end
end
