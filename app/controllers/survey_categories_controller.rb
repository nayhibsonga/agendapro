class SurveyCategoriesController < ApplicationController
  before_action :set_survey_category, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @survey_categories = SurveyCategory.all
    respond_with(@survey_categories)
  end

  def show
    respond_with(@survey_category)
  end

  def new
    @survey_category = SurveyCategory.new
    respond_with(@survey_category)
  end

  def edit
  end

  def create
    @survey_category = SurveyCategory.new(survey_category_params)
    @survey_category.save
    respond_with(@survey_category)
  end

  def update
    @survey_category.update(survey_category_params)
    respond_with(@survey_category)
  end

  def destroy
    @survey_category.destroy
    respond_with(@survey_category)
  end

  private
    def set_survey_category
      @survey_category = SurveyCategory.find(params[:id])
    end

    def survey_category_params
      params.require(:survey_category).permit(:name, :company_id)
    end
end
