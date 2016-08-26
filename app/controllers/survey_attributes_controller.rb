class SurveyAttributesController < ApplicationController
  before_action :set_survey_attribute, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @survey_attributes = SurveyAttribute.all
    respond_with(@survey_attributes)
  end

  def show
    respond_with(@survey_attribute)
  end

  def new
    @survey_attribute = SurveyAttribute.new
    respond_with(@survey_attribute)
  end

  def edit
  end

  def create
    @survey_attribute = SurveyAttribute.new(survey_attribute_params)
    @survey_attribute.save
    respond_with(@survey_attribute)
  end

  def update
    @survey_attribute.update(survey_attribute_params)
    respond_with(@survey_attribute)
  end

  def destroy
    @survey_attribute.destroy
    respond_with(@survey_attribute)
  end

  private
    def set_survey_attribute
      @survey_attribute = SurveyAttribute.find(params[:id])
    end

    def survey_attribute_params
      params.require(:survey_attribute).permit(:name, :description)
    end
end
