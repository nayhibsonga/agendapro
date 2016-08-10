class SurveysController < ApplicationController
  before_action :set_survey, only: [:show, :edit, :update, :destroy]

  def index
    @surveys = Survey.all

  end

  def show
    respond_with(@survey)
  end

  def new
    @survey = Survey.new
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    id = crypt.decrypt_and_verify(params[:confirmation_code])
    @booking = Booking.find(id)
  end

  def edit
  end

  def create
    @survey = Survey.new(survey_params)
    if @survey.save
      respond_to do |format|
        format.json {render json: @survey}
      end
    else
      respond_to do |format|
        format.json {render json: @survey.errors}
      end
    end
  end

  def update
    @survey.update(survey_params)
    respond_with(@survey)
  end

  def destroy
    @survey.destroy
    respond_with(@survey)
  end

  private
    def set_survey
      @survey = Survey.find(params[:id])
    end

    def survey_params
      params.require(:survey).permit(:quality, :style, :satifaction, :comment, :client_id)
    end
end
