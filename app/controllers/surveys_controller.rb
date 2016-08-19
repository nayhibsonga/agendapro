class SurveysController < ApplicationController
  before_action :set_survey, only: [:show, :edit, :update, :destroy]

  def index
    @surveys = Survey.all
  end

  def show
    respond_with(@survey)
  end

  def new
    decrypt(params[:confirmation_code])
    @survey = Survey.find(@booking.survey_id)
    @survey_answer = SurveyAnswer.new
    @error = "Booking no invalido."
    if @booking
      @found = true
    else
      @found = false
    end
  end

  def edit
  end

  def create
    @params = survey_params
    decrypt(@params[:booking_id])
    if @booking
      @params[:booking_id] = @booking.id
      @params[:client_id] = @booking.client.id
      @survey = Survey.new(@params)
      if @survey.save
        respond_to do |format|
          format.json {render json: @survey, :status => :created}
        end
        @booking.update(survey_id:@survey.id)

      else
        respond_to do |format|
          format.json {render json: @survey.errors, :status => :unauthorized}
        end
      end
    else
      respond_to do |format|
        format.json {render json: @booking, :status => :not_found}
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
      params.require(:survey).permit(:quality, :style, :satifaction, :comment, :booking_id)
    end
    def decrypt(key)
      begin
        crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
        @id = crypt.decrypt_and_verify(key)
        @booking = Booking.find_by(id:@id)
      rescue
        @error
      rescue Exception
        @error
      end
    end

end
