class SurveysController < ApplicationController
  layout "survey"
  before_action :set_survey, only: [:show, :edit, :update, :destroy]

  def index
    @surveys = SurveyCategory.all
    respond_with(@surveys)
  end

  def show
    respond_with(@survey)
  end

  def new
    @survey = SurveyCategory.new
    respond_with(@survey)
  end

  def edit
  end

  def create
    @survey = SurveyCategory.new(survey_params)
    @survey.save
    respond_with(@survey)
  end

  def update
    @survey.update(survey_category_params)
    respond_with(@survey)
  end

  def destroy
    @survey.destroy
    respond_with(@survey)
  end

  private
    def set_survey
      @survey = SurveyCategory.find(params[:id])
    end

    def survey_category
      params.require(:survey).permit(:name, :company_id)
    end

end
