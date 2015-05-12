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
    flash[:notice] = "Configuración guardada"
    respond_with(@notification_email, :location => edit_company_setting_path(User.find(current_user.id).company.company_setting)) #no funciona en caso de error
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
      params.require(:notification_email).permit(:company_id, :email, :notification_type, :receptor_type, :summary, :new, :modified, :confirmed, :canceled, :new_web, :modified_web, :confirmed_web, :canceled_web, location_ids: [], service_provider_ids: [])
    end
end
