class CompanyFromEmailsController < ApplicationController
  before_action :set_company_from_email, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"
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
        format.html { redirect_to @company_from_email, notice: 'Company from email was successfully created.' }
        format.json { render action: 'show', status: :created, location: @company_from_email }
      else
        format.html { render action: 'new' }
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
      format.html { redirect_to company_from_emails_url }
      format.json { head :no_content }
    end
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
