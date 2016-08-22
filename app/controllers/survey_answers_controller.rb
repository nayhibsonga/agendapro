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
    @survey = Survey.find(@booking.survey_id)
    @survey_answer = SurveyAnswer.new
    @logo = @survey.bookings.first.client.company.logo.url
    @company = @survey.bookings.first.client.company.name
    @error = "Booking no valido."
    if @booking
      @found = true
    else
      @found = false
    end
    respond_with(@survey_answer)
  end

  def edit
  end

  def create
    survey_answer_params.each do |key,value|
      hash =  Hash.new {hash[key] = value }
      @survey_answer = SurveyAnswer.new(hash)
      @survey_answer.save
    end
    respond_with(@survey_answer)
    raise "asdf"
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
