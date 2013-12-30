class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:new, :workflow]
  before_action :verify_is_super_admin, except: [:new, :workflow]

  layout "admin", except: [:show, :workflow]


  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.all
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
    @user = User.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)
    @user = User.new(user_params)

    @user.role = Role.find_by_name("Admin")
    @user.company = @company

    respond_to do |format|
      if @company.save && @user.save
        format.html { redirect_to @company, notice: 'La empresa fue creada exitosamente.' }
        format.json { render action: 'show', status: :created, location: @company }
      else
        format.html { render action: 'new' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'La empresa fue actualizada exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end

  ##### Workflow #####
  def workflow
    @company = Company.find_by(web_address: request.subdomain)
    if @company.nil?
      flash[:alert] = "No existe la compañia"
      redirect_to root_url(:host => request.domain + request.port_string)
    end
    @locations = Location.where('company_id = ?', @company.id)

    #Selected local from fase II
    @selectedLocal = params[:local]
    render layout: "workflow"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :economic_sector_id, :plan_id, :logo, :payment_status_id, :pay_due, :web_address, :users_attributes[:id, :first_name, :last_name, :email, :phone, :user_name, :password, :role_id, :company_id])
    end
end
