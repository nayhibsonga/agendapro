class SurveyAnswersController < ApplicationController
  layout "survey"
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
    decrypt(params[:confirmation_code])
    if @booking
      if @booking.survey.status == "respond"
        @found = false
        @error = "Encuesta ya respondida."
        flash[:error] = "Encuesta ya respondida."
      else
        @found = true
        @i = 1;
        @survey = @booking.survey
        @booking_client_id = @booking.client.id
        @valoration = params[:valoration]
        @survey_answer = SurveyAnswer.new
        @logo = @survey.bookings.first.client.company.logo.url
        @company = @survey.bookings.first.client.company.name
        if (1..5).include?(@valoration.to_i)
          if @survey.appreciation.nil?
            flash[:notice] = "Valoración recibida."
            @survey.appreciation = @valoration.to_i
            @survey.client_id = @booking_client_id
          end
        end
        @survey.save
      end
    else
      @error = "Booking no válido."
      flash[:error] = "Booking no válido."
      @found = false
    end
    respond_with(@survey_answer)
  end

  def edit
  end

  def create
    survey_answer_params.each do |answers|
      answers.each do |key, value|
        if key == "booking_id"
          @booking_id = value
        elsif key == "survey_question_id"
          @survey_question_id = value
        else
          answer = value
          @survey_answer = SurveyAnswer.new(:booking_id => @booking_id, :answer => answer, :survey_question_id => @survey_question_id)
          @survey_answer.save
        end
      end
    end
    @survey = Booking.find(@booking_id).survey
    @survey.status = "respond"
    @survey.save
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
      @survey = Survey.find(params[:id])
    end

    def survey_answer_params
      params.require(:survey_answer)
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
