class NotificationEmailsController < ApplicationController
  before_action :set_notification_email, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  respond_to :html

  def index
    @notification_emails = NotificationEmail.all
    respond_with(@notification_emails)
  end

  def show
    respond_with(@notification_email)
  end

  def new
    @notification_email = NotificationEmail.new
    respond_with(@notification_email)
  end

  def edit
  end

  def create
    @notification_email = NotificationEmail.new(notification_email_params)
    @notification_email.save
    respond_with(@notification_email)
  end

  def update
    @notification_email.update(notification_email_params)
    respond_with(@notification_email)
  end

  def destroy
    @notification_email.destroy
    respond_with(@notification_email)
  end

  private
    def set_notification_email
      @notification_email = NotificationEmail.find(params[:id])
    end

    def notification_email_params
      params.require(:notification_email).permit(:company_id, :emails, :notification_type, :receptor_type)
    end
end
