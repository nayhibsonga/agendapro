class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:new, :overview, :workflow, :check_company_web_address]
  before_action :quick_add, except: [:new, :overview, :workflow, :add_company, :check_company_web_address]
  before_action :verify_is_super_admin, only: [:index]

  layout "admin", except: [:show, :overview, :workflow, :add_company]
  load_and_authorize_resource


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
    @company.payment_status_id = PaymentStatus.find_by_name("Período de Prueba").id
    @company.plan_id = Plan.find_by_name("Trial").id
    @user = User.find(current_user.id)
    
    respond_to do |format|
      if @company.save 
        @user.company_id = @company.id
        @user.role_id = Role.find_by_name("Admin").id
        @user.save
        format.html { redirect_to dashboard_path, notice: 'La empresa fue creada exitosamente.' }
        format.json { render action: 'show', status: :created, location: @company }
      else
        format.html { render action: 'add_company', layout: "search" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to companies_path, notice: 'La empresa fue actualizada exitosamente.' }
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
  def overview
    @company = Company.find_by(web_address: request.subdomain)
    if @company.nil?
      flash[:alert] = "No existe la compañia"

      host = request.host_with_port
      domain = host[host.index(request.domain)..host.length]

      redirect_to root_url(:host => domain)
      return
    end
    @locations = Location.where('company_id = ?', @company.id)

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    #Selected local from fase II
    @selectedLocal = params[:local]
    render layout: "workflow"
  end

  def workflow
    @company = Company.find_by(web_address: request.subdomain)
    @location = Location.find(params[:local])

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]
    
    render layout: 'workflow'
  end

  def add_company
    if current_user.company_id
      redirect_to dashboard_path
    end
    @company = Company.new
    render :layout => 'search'
  end

  def check_company_web_address
    begin
		@company = Company.find_by(:web_address => params[:user][:company_attributes][:web_address])
	rescue
		@company = Company.find_by(:web_address => params[:company][:web_address])
	end
	render :json => @company.nil?
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :economic_sector_id, :plan_id, :logo, :remove_logo, :payment_status_id, :pay_due, :web_address, :description, :cancellation_policy)
      #params.require(:company).permit(:name, :economic_sector_id, :plan_id, :logo, :payment_status_id, :pay_due, :web_address, :users_attributes[:id, :first_name, :last_name, :email, :phone, :user_name, :password, :role_id, :company_id])
    end
end
