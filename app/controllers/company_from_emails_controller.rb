class CompanyFromEmailsController < ApplicationController
  before_action :set_company_from_email, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:confirm_email]
  layout "admin", except: [:confirm_email]
  # load_and_authorize_resource

  # GET /company_from_emails
  # GET /company_from_emails.json
  def index
    @company_from_emails = CompanyFromEmail.where(:company => current_user.company)
  end

  # GET /company_from_emails/1
  # GET /company_from_emails/1.json
  def show
  end

  # GET /company_from_emails/new
  def new
    @company_from_email = CompanyFromEmail.new
  end

  # GET /company_from_emails/1/edit
  def edit
  end

  # POST /company_from_emails
  # POST /company_from_emails.json
  def create
    @company_from_email = CompanyFromEmail.new(company_from_email_params)

    respond_to do |format|
      if @company_from_email.save
        CompanyFromEmailMailer.confirm_email(@company_from_email, current_user)
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting), notice: 'E-mail agregado exitosamente. Se ha enviado un correo para verificar la nueva dirección.' }
        format.json { render action: 'show', status: :created, location: @company_from_email }
      else
        format.html { redirect_to edit_company_setting_path, notice: 'No se pudo agregar el email. Por favor inténtalo nuevamente.' }
        format.json { render json: @company_from_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /company_from_emails/1
  # PATCH/PUT /company_from_emails/1.json
  def update
    respond_to do |format|
      if @company_from_email.update(company_from_email_params)
        format.html { redirect_to @company_from_email, notice: 'Company from email was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company_from_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /company_from_emails/1
  # DELETE /company_from_emails/1.json
  def destroy
    @company_from_email.destroy
    respond_to do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting), notice: 'E-mail eliminado exitosamente.' }
      format.json { head :no_content }
    end
  end

  def confirm_email
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    id = crypt.decrypt_and_verify(params[:confirmation_code])
    @email = CompanyFromEmail.find(id)

    @email.update(:confirmed => true)

    render layout: 'login'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_from_email
      @company_from_email = CompanyFromEmail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_from_email_params
      params.require(:company_from_email).permit(:email, :company_id)
    end
end
