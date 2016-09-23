class SurveyAnswersController < ApplicationController
  layout "admin"
  before_action :set_survey_answer, only: [:edit, :update, :destroy]
  before_action :average, only: [:status_details, :index]
  before_action :set_params, only: [:status_details, :index]
  respond_to :html

  def index
    @survey_answers = SurveyAnswer.all
    respond_with(@survey_answers)
  end

  def show
    #respond_with(@survey_answer)
  end

  def average

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
    respond_to do |format|
      format.html {render layout: "survey"}
    end
    #respond_with(@survey_answer)
  end

  def edit
  end

  def status_details

    surveys_general = Booking.where(location_id: Location.where(company_id: current_user.company_id).pluck(:id),survey_id: Survey.where(created_at: @from.beginning_of_day..@to.end_of_day)).where.not(survey_id:nil)
    surveys = surveys_general.where(survey_id: Survey.where.not(appreciation: nil).pluck(:id))
    @surveys_send = surveys_general.where(survey_id: Survey.where(mail_sent: true).pluck(:id))
    @surveys_respond = surveys_general.where(survey_id: Survey.where(status: "respond").pluck(:id))
    @surveys_percentil = 0
    if surveys_general.count > 0
      @surveys_percentil = ((@surveys_respond.count.to_i * 100).to_f / @surveys_send.count.to_f).round(2)
    end

    @average = 0
    if surveys.count > 0
      surveys.each do |s|
        @average = @average + s.survey.appreciation
      end
      @average = @average.to_f / surveys.count.to_f
    else
      @image_average = "appreciation_0.png"
    end

    if @average >= 1 &&  @average < 2
      @image_average = "appreciation_1.png"
    elsif @average >= 2 &&  @average < 3
      @image_average = "appreciation_2.png"
    elsif @average >= 3 &&  @average < 4
      @image_average = "appreciation_3.png"
    elsif @average >= 4 &&  @average < 5
      @image_average = "appreciation_4.png"
    elsif @average >= 4.5
      @image_average = "appreciation_5.png"
    end

    @survey_attributes_eva = []

    SurveyAnswer.where(booking_id: Booking.where(location_id: Location.where(company_id: current_user.company_id).pluck(:id)), created_at: @from.beginning_of_day..@to.end_of_day).each do |eva|
      if !@survey_attributes_eva.include?(eva.survey_question.survey_attribute)
        @survey_attributes_eva << eva.survey_question.survey_attribute
      end
    end

    render "_status_details", layout: false

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

    def set_params
      @from = params[:from].blank? ? Time.now.beginning_of_day : Time.parse(params[:from]).beginning_of_day
      @to = params[:to].blank? ? Time.now.end_of_day : Time.parse(params[:to]).end_of_day
    end

end
