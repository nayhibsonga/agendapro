class CompaniesController < ApplicationController
  before_action :verify_is_active, only: [:overview, :workflow]
	before_action :set_company, only: [:show, :edit, :update, :destroy, :edit_payment]
	before_action :constraint_locale, only: [:overview, :workflow]
	before_action :authenticate_user!, except: [:new, :overview, :workflow, :check_company_web_address, :select_hour, :user_data, :select_promo_hour, :mobile_hours]
	before_action :quick_add, except: [:new, :overview, :workflow, :add_company, :check_company_web_address, :select_hour, :user_data, :select_promo_hour, :mobile_hours]
	before_action :verify_is_super_admin, only: [:index, :edit_payment, :new, :edit, :manage, :manage_company, :new_payment, :add_payment, :update_company, :get_year_incomes, :incomes, :locations, :monthly_locations, :deactivate_company]

	layout "admin", except: [:show, :overview, :workflow, :add_company, :select_hour, :user_data, :select_session_hour, :select_promo_hour]
	load_and_authorize_resource


	# GET /companies
	# GET /companies.json
	def index
		@companies = Company.all.order(:name)
	end

	#SuperAdmin
	#Manage companies payments.
	def manage
		if current_user.role_id == Role.find_by_name("Ventas").id
			@companies = StatsCompany.where(company_sales_user_id: current_user.id)
			@active_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Activo').id).order(:company_name)
			@trial_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Trial').id).order(:company_name)
			@late_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Vencido').id).order(:company_name)
			@blocked_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Bloqueado').id).order(:company_name)
			@inactive_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Inactivo').id).order(:company_name)
			@issued_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Emitido').id).order(:company_name)
			@pac_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Convenio PAC').id).order(:company_name)
		else
			if I18n.locale == :es
				@companies = StatsCompany.all.order(:company_name)
			else
				@companies = StatsCompany.where(company_id: Company.where(country_id: Country.find_by(locale: I18n.locale.to_s))).order(:company_name)
			end
			@active_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Activo').id).order(:company_name)
			@trial_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Trial').id).order(:company_name)
			@late_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Vencido').id).order(:company_name)
			@blocked_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Bloqueado').id).order(:company_name)
			@inactive_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Inactivo').id).order(:company_name)
			@issued_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Emitido').id).order(:company_name)
			@pac_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Convenio PAC').id).order(:company_name)
		end
	end

	#SuperAdmin
	#Manage company sheet.
	def manage_company
		@company = Company.find(params[:id])
		@bookings = Array.new
		@company.locations.each do |location|
			location.bookings.each do |booking|
				@bookings << booking
			end
		end
		@company.payment_status == PaymentStatus.find_by_name("Trial") ? @price = Plan.where(custom: false).where('locations >= ?', @company.locations.where(active: true).count).where('service_providers >= ?', @company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: @company.country.id).price : @price = @company.plan.plan_countries.find_by(country_id: @company.country.id).price
		@sales_tax = @company.country.sales_tax
	    @month_discount_4 = NumericParameter.find_by_name("4_month_discount").value
	    @month_discount_6 = NumericParameter.find_by_name("6_month_discount").value
	    @month_discount_9 = NumericParameter.find_by_name("9_month_discount").value
	    @month_discount_12 = NumericParameter.find_by_name("12_month_discount").value



	    @day_number = Time.now.day
	    @month_number = Time.now.month
	    @month_days = Time.now.days_in_month
		@company.months_active_left > 0 ? @plan_1 = (@company.due_amount + @price).round(0) : @plan_1 = ((@company.due_amount + (@month_days - @day_number + 1)*@price/@month_days)).round(0)


	    @plan_2 = (@plan_1 + @price*1).round(0)
	    @plan_3 = (@plan_1 + @price*2).round(0)
	    @plan_4 = ((@plan_1 + @price*3)*(1-@month_discount_4)).round(0)
	    @plan_6 = ((@plan_1 + @price*5)*(1-@month_discount_6)).round(0)
	    @plan_9 = ((@plan_1 + @price*8)*(1-@month_discount_9)).round(0)
	    @plan_12 = ((@plan_1 + @price*11)*(1-@month_discount_12)).round(0)
	end

	#SuperAdmin
	#Add manual payment (billingRecord) to a company
	def new_payment
		@company = Company.find(params[:id])
	end

	#SuperAdmin
	def add_payment
		@company = Company.find(params[:id])
		amount = params[:amount].to_f
		date = Date.parse(params[:date])
		billing_record = BillingRecord.new
		billing_record.company_id = @company.id
		billing_record.amount = amount
		billing_record.transaction_type_id = params[:transaction_type_id]
		billing_record.date = date
		if billing_record.save
			if @company.plan.id != params[:new_plan_id]
				@company.plan_id = params[:new_plan_id]
			end
			if params[:new_due] != ""
				@company.due_amount = params[:new_due].to_f
			end
			if params[:new_months] != ""
				@company.months_active_left = params[:new_months].to_f
			end
			if @company.payment_status_id != params[:new_status_id]
				@company.payment_status_id = params[:new_status_id]
			end

			@company.save

			redirect_to :action => 'manage_company', :id => @company.id
		else
			redirect_to :action => 'new_payment', :id => @company.id, :alert => 'Ocurrió un error al ingresar el pago.'
		end
	end


	def payment

		@record = BillingRecord.find(params[:id])
		@company = @record.company

	end

	def delete_payment
		@record = BillingRecord.find(params[:record_id])
		@company = Company.find(params[:id])
		if @record.delete
			flash[:notice] = 'Pago eliminado correctamente.'
			redirect_to :action => 'manage_company', :id => @company.id
		else
			flash[:alert] = 'Ocurrió un error al eliminar el pago.'
			redirect_to :action => 'manage_company', :id => @company.id
		end
	end

	def modify_payment

		@record = BillingRecord.find(params[:id])
		if params[:amount].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			@record.amount = params[:amount].to_f
		end
		if params[:date] != ""
			date = Date.parse(params[:date])
			@record.date = date
		end
		@record.transaction_type_id = params[:transaction_type_id]
		@company = @record.company

		if @record.save
			if @company.plan.id != params[:new_plan_id]
				@company.plan_id = params[:new_plan_id]
			end
			if params[:new_due] != ""
				@company.due_amount = params[:new_due].to_f
			end
			if params[:new_months] != ""
				@company.months_active_left = params[:new_months].to_f
			end
			if @company.payment_status_id != params[:new_status_id]
				@company.payment_status_id = params[:new_status_id]
			end
			@company.save
			redirect_to :action => 'manage_company', :id => @company.id
		else
			redirect_to :action => 'payment', :id => @record.id, :alert => 'Ocurrió un error al modificar el pago.'
		end

	end


	#SuperAdmin
	def update_company

		@company = Company.find(params[:id])
		@company.payment_status_id = params[:new_payment_status_id]
		@company.sales_user_id = params[:sales_user_id]
		@company.plan_id = params[:new_plan_id]
		if params[:new_due_amount].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			@company.due_amount = params[:new_due_amount]
		end
		if params[:new_months_active_left].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			@company.months_active_left = params[:new_months_active_left]
		end
		if params[:new_online_payment_commission].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			@company.company_setting.online_payment_commission = params[:new_online_payment_commission].to_f
			@company.company_setting.save
		end
		if params[:new_promo_commission].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			@company.company_setting.promo_commission = params[:new_promo_commission].to_f
			@company.company_setting.save
		end

		@company.company_setting.online_payment_capable = params[:new_online_payment_capable]
		@company.company_setting.promo_offerer_capable = params[:new_promo_offerer_capable]
		@company.company_setting.save

		if @company.company_setting.promo_time.nil?
			promo_time = PromoTime.new
			promo_time.company_setting_id = @company.company_setting.id
			promo_time.save
		end

		if @company.payment_status_id != PaymentStatus.find_by_name("Inactivo").id and @company.payment_status_id != PaymentStatus.find_by_name("Bloqueado").id
			@company.active = true
		else
			@company.active = false
		end

		if @company.save
			flash[:notice] = 'Companía editada correctamente.'
			redirect_to :action => 'manage_company', :id => @company.id
		else
			flash[:alert] = 'Ocurrió un error al editar la compañía.'
			redirect_to :action => 'manage_company', :id => @company.id
		end

	end

	#SuperAdmin
	#Return a hash of incomes per month
	def get_year_incomes

		@incomes = Hash.new

		total = 0
		year = params[:year].to_i

		for i in 1..13 do
			@incomes[i] = Hash.new
			@incomes[i]['month'] = ""
			@incomes[i]['income'] = 0
		end

		@incomes[1]['month'] = "Enero"
		@incomes[2]['month'] = "Febrero"
		@incomes[3]['month'] = "Marzo"
		@incomes[4]['month'] = "Abril"
		@incomes[5]['month'] = "Mayo"
		@incomes[6]['month'] = "Junio"
		@incomes[7]['month'] = "Julio"
		@incomes[8]['month'] = "Agosto"
		@incomes[9]['month'] = "Septiembre"
		@incomes[10]['month'] = "Octubre"
		@incomes[11]['month'] = "Noviembre"
		@incomes[12]['month'] = "Diciembre"

		@company = Company.find(params[:id])
		for i in 1..12 do

			month_income = 0

			start_date = DateTime.new(year, i, 1)
			end_date = start_date
			if i < 12
				end_date = DateTime.new(year, i+1, 1)-1.minutes
			else
				end_date = DateTime.new(year+1, 1, 1)-1.minutes
			end
			billing_logs = BillingLog.where('company_id = ? and created_at BETWEEN ? and ?', @company.id, start_date, end_date).where(:trx_id => PuntoPagosConfirmation.where(:response => "00").pluck(:trx_id))
			billing_records = BillingRecord.where('company_id = ? and date BETWEEN ? and ?', @company.id, start_date, end_date)

			billing_logs.each do |bl|
				month_income = month_income + bl.payment
				total = total + bl.payment
			end
			billing_records.each do |br|
				month_income = month_income + br.amount
				total = total + br.amount
			end

			@incomes[i]['income'] = month_income

		end
		@incomes[13]['month'] = 'Total'
		@incomes[13]['income'] = total

		render :json => @incomes

	end

	#SuperAdmin
	def get_year_bookings
		@bookings = Hash.new

		total = 0
		year = params[:year].to_i

		for i in 1..13 do
			@bookings[i] = Hash.new
			@bookings[i]['month'] = ""
			@bookings[i]['count'] = 0
		end

		@bookings[1]['month'] = "Enero"
		@bookings[2]['month'] = "Febrero"
		@bookings[3]['month'] = "Marzo"
		@bookings[4]['month'] = "Abril"
		@bookings[5]['month'] = "Mayo"
		@bookings[6]['month'] = "Junio"
		@bookings[7]['month'] = "Julio"
		@bookings[8]['month'] = "Agosto"
		@bookings[9]['month'] = "Septiembre"
		@bookings[10]['month'] = "Octubre"
		@bookings[11]['month'] = "Noviembre"
		@bookings[12]['month'] = "Diciembre"

		@company = Company.find(params[:id])

		for i in 1..12 do

			month_bookings = 0

			start_date = DateTime.new(year, i, 1)
			end_date = start_date
			if i < 12
				end_date = DateTime.new(year, i+1, 1)-1.minutes
			else
				end_date = DateTime.new(year+1, 1, 1)-1.minutes
			end


			month_bookings = Booking.where('start BETWEEN ? and ?', start_date, end_date).where(:location_id => @company.locations.pluck(:id)).count


			@bookings[i]['count'] = month_bookings
			total = total + month_bookings

		end

		@bookings[13]['count'] = total
		@bookings[13]['month'] = "Total"

		render :json => @bookings

	end

	#SuperAdmin
	def incomes

		# @companies = Company.where(active: true).where.not(payment_status_id: PaymentStatus.find_by_name('Inactivo').id).order(:name)

		@companies = Company.all.order(:name)

		@year = DateTime.now.year.to_i
		if params[:year]
			@year = params[:year].to_i
		end

		@incomes = Hash.new
		for i in 1..13
			@incomes[i] = Hash.new
			@incomes[i]['month'] = ""
			@incomes[i]['income'] = 0
		end

		@incomes[1]['month'] = "Enero"
		@incomes[2]['month'] = "Febrero"
		@incomes[3]['month'] = "Marzo"
		@incomes[4]['month'] = "Abril"
		@incomes[5]['month'] = "Mayo"
		@incomes[6]['month'] = "Junio"
		@incomes[7]['month'] = "Julio"
		@incomes[8]['month'] = "Agosto"
		@incomes[9]['month'] = "Septiembre"
		@incomes[10]['month'] = "Octubre"
		@incomes[11]['month'] = "Noviembre"
		@incomes[12]['month'] = "Diciembre"

	end

	#SuperAdmin
	def monthly_bookings

		@year = DateTime.now.year.to_i
		if params[:year]
			@year = params[:year].to_i
		end

		#start_date = DateTime.new(@year, 1, 1)
		#end_date = DateTime.new(@year+1, 1, 1) -1.minutes

		@companies = Company.all.order(:name)
		#.where(:id => Location.where('created_at BETWEEN ? and ?', start_date, end_date).pluck('company_id'))

		@bookings = Hash.new
		for i in 1..13
			@bookings[i] = Hash.new
			@bookings[i]['month'] = ""
			@bookings[i]['count'] = 0
			@bookings[i]['web'] = 0
		end

		@bookings[1]['month'] = "Enero"
		@bookings[2]['month'] = "Febrero"
		@bookings[3]['month'] = "Marzo"
		@bookings[4]['month'] = "Abril"
		@bookings[5]['month'] = "Mayo"
		@bookings[6]['month'] = "Junio"
		@bookings[7]['month'] = "Julio"
		@bookings[8]['month'] = "Agosto"
		@bookings[9]['month'] = "Septiembre"
		@bookings[10]['month'] = "Octubre"
		@bookings[11]['month'] = "Noviembre"
		@bookings[12]['month'] = "Diciembre"

		@cat_bookings = Hash.new
		for i in 1..13
			@cat_bookings[i] = Hash.new
			@cat_bookings[i]['month'] = ""
			@cat_bookings[i]['count'] = 0
			@cat_bookings[i]['web'] = 0
		end

		@cat_bookings[1]['month'] = "Enero"
		@cat_bookings[2]['month'] = "Febrero"
		@cat_bookings[3]['month'] = "Marzo"
		@cat_bookings[4]['month'] = "Abril"
		@cat_bookings[5]['month'] = "Mayo"
		@cat_bookings[6]['month'] = "Junio"
		@cat_bookings[7]['month'] = "Julio"
		@cat_bookings[8]['month'] = "Agosto"
		@cat_bookings[9]['month'] = "Septiembre"
		@cat_bookings[10]['month'] = "Octubre"
		@cat_bookings[11]['month'] = "Noviembre"
		@cat_bookings[12]['month'] = "Diciembre"

	end

	#CSV generation
	def get_monthly_bookings
		filename = params[:type] + "_" + params[:subtype]
		year = params[:year]
		filename = filename + "_" + year + ".csv"

	    send_data Booking.generate_csv(params[:type], params[:subtype], params[:year]), filename: filename

	end

	#SuperAdmin
	def locations

		@year = DateTime.now.year.to_i
		if params[:year]
			@year = params[:year].to_i
		end

		@companies_arr = Array.new

		for i in 1..12
			@companies_arr[i] = Hash.new
			@companies_arr[i]['month'] = ""

			start_date = DateTime.new(@year, i, 1)
			end_date = start_date
			if i < 12
				end_date = DateTime.new(@year, i+1, 1)-1.minutes
			else
				end_date = DateTime.new(@year+1, 1, 1)-1.minutes
			end

			@companies_arr[i]['companies'] = Company.where('created_at BETWEEN ? and ?', start_date, end_date).order(:name)
		end

		@companies_arr[1]['month'] = "Enero"
		@companies_arr[2]['month'] = "Febrero"
		@companies_arr[3]['month'] = "Marzo"
		@companies_arr[4]['month'] = "Abril"
		@companies_arr[5]['month'] = "Mayo"
		@companies_arr[6]['month'] = "Junio"
		@companies_arr[7]['month'] = "Julio"
		@companies_arr[8]['month'] = "Agosto"
		@companies_arr[9]['month'] = "Septiembre"
		@companies_arr[10]['month'] = "Octubre"
		@companies_arr[11]['month'] = "Noviembre"
		@companies_arr[12]['month'] = "Diciembre"

	end

	#SuperAdmin
	def monthly_locations

		#@companies = Company.all.order(:name)

		@year = DateTime.now.year.to_i
		if params[:year]
			@year = params[:year].to_i
		end

		start_date = DateTime.new(@year, 1, 1)
		end_date = DateTime.new(@year+1, 1, 1) -1.minutes

		@companies = Company.where(:id => Location.where('created_at BETWEEN ? and ?', start_date, end_date).pluck('company_id'))

		@locations = Hash.new
		for i in 1..13
			@locations[i] = Hash.new
			@locations[i]['month'] = ""
			@locations[i]['count'] = 0
		end

		@locations[1]['month'] = "Enero"
		@locations[2]['month'] = "Febrero"
		@locations[3]['month'] = "Marzo"
		@locations[4]['month'] = "Abril"
		@locations[5]['month'] = "Mayo"
		@locations[6]['month'] = "Junio"
		@locations[7]['month'] = "Julio"
		@locations[8]['month'] = "Agosto"
		@locations[9]['month'] = "Septiembre"
		@locations[10]['month'] = "Octubre"
		@locations[11]['month'] = "Noviembre"
		@locations[12]['month'] = "Diciembre"

	end


	def deactivate_company
		@company = Company.find(params[:id])
		@company.active = false
		@company.due_amount = 0
		@company.months_active_left = 0
		@company.payment_status_id = PaymentStatus.find_by_name("Inactivo").id
		if @company.save
			flash[:notice] = 'Companía editada correctamente.'
			redirect_to :action => 'manage_company', :id => @company.id
		else
			flash[:alert] = 'Ocurrió un error al editar la compañía.'
			redirect_to :action => 'manage_company', :id => @company.id
		end
	end


	def activate
		@company.active = true
		@company.save
		redirect_to companies_path
	end

	def deactivate
		@company.active = false
		@company.save
		redirect_to companies_path
	end

	def add_month
		company = Company.find(params[:id])
		if company.payment_status == PaymentStatus.find_by_name("Trial")
			company.plan = Plan.where(custom: false, locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first
		end
        company.months_active_left += 1
        company.due_amount = 0.0
        company.due_date = nil
        company.payment_status_id = PaymentStatus.find_by_name("Activo").id
        if company.save
          CompanyCronLog.create(company_id: company.id, action_ref: 9, details: "OK add_admin_month")
          flash[:notice] = 'Mes agregado exitosamente.'
          redirect_to edit_payment_company_path(company)
        else
          CompanyCronLog.create(company_id: company.id, action_ref: 9, details: "ERROR add_admin_month "+company.errors.full_messages.inspect)
          flash[:alert] = 'Error al agregar mes.'
          redirect_to edit_payment_company_path(company)
        end
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

	def edit_payment
	end

	# POST /companies
	# POST /companies.json
	def create
		@company = Company.new(company_params)
		@user = User.find(current_user.id)
		if @user.role_id != Role.find_by_name("Super Admin").id
			@company.payment_status_id = PaymentStatus.find_by_name("Trial").id
			@company.plan_id = Plan.find_by_name("Trial").id
		else
			@company.payment_status_id = PaymentStatus.find_by_name("Admin").id
			@company.plan_id = Plan.find_by_name("Admin").id
			@company.build_company_setting
			@company.company_setting.build_online_cancelation_policy
			@company.owned = false
		end

		respond_to do |format|
			if @company.save
				if @user.role_id != Role.find_by_name("Super Admin").id
					@user.company_id = @company.id
					@user.role_id = Role.find_by_name("Administrador General").id
					@user.save
				end
				format.html { redirect_to dashboard_path, notice: 'Empresa creada exitosamente.' }
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
				format.html { redirect_to edit_company_setting_path(@company.company_setting, anchor: 'company'), notice: 'Empresa actualizada exitosamente.' }
				format.json { head :no_content }
			else
				format.html { render 'company_settings/edit' }
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

		@company = CompanyCountry.find_by(web_address: request.subdomain, country_id: Country.find_by(locale: I18n.locale.to_s)) ? CompanyCountry.find_by(web_address: request.subdomain, country_id: Country.find_by(locale: I18n.locale.to_s)).company : nil
		if @company.nil?
			@company = CompanyCountry.find_by(web_address: request.subdomain.gsub(/www\./i, ''), country_id: Country.find_by(locale: I18n.locale.to_s)) ? CompanyCountry.find_by(web_address: request.subdomain.gsub(/www\./i, ''), country_id: Country.find_by(locale: I18n.locale.to_s)).company : nil
			if @company.nil?
				flash[:alert] = "No existe la compañia buscada."

				host = request.host_with_port
				domain = host[host.index(request.domain)..host.length]

				redirect_to root_url(:host => domain)
				return
			end
		end

		@locations = Location.where(:active => true, online_booking: true, district_id: District.where(city_id: City.where(region_id: Region.where(country_id: Country.find_by(locale: I18n.locale.to_s))))).where(company_id: @company.id).where(id: ServiceProvider.where(active: true, company_id: @company.id, online_booking: true).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: @company.id, online_booking: true).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(:order, :name)

		unless @company.company_setting.activate_workflow && @company.active && @locations.count > 0
			flash[:alert] = "Lo sentimos, el mini-sitio que estás buscando no se encuentra disponible."

			host = request.host_with_port
			domain = host[host.index(request.domain)..host.length]

			redirect_to root_url(:host => domain)
			return
		end

		@has_images = false
		@locations.each do |location|
			tmp = !(location.image1.url.include? "rectangulo_gris.png") || !(location.image2.url.include? "rectangulo_gris.png") || !(location.image3.url.include? "rectangulo_gris.png")
			@has_images = tmp && @has_images
		end

		# => Domain parser
		host = request.host_with_port
		@url = @company.company_countries.find_by(country_id: Country.find_by(locale: I18n.locale.to_s)).web_address + '.' + host[host.index(request.domain)..host.length] + '/' + I18n.locale.to_s

		#Selected local from fase II
		if(params[:local])
			@selectedLocal = params[:local]
			if Location.where(:id => @selectedLocal).count > 0
				@selectedLocation = Location.find(@selectedLocal)
			else
				flash[:alert] = "Lo sentimos, el local ingresado no existe."
			end
		else
			@selectedLocation = @locations.first
			@selectedLocal = @selectedLocation.id
		end

		if mobile_request?
			@url = @company.company_countries.find_by(country_id: Country.find_by(locale: I18n.locale.to_s)).web_address + '.' + host[host.index(request.domain)..host.length]
			if params[:local]
				redirect_to workflow_path(:local => params[:local])
				return
			else
				if @locations.length == 1
					redirect_to workflow_path(:local => @locations[0].id)
					return
				end
			end
		end
		render layout: "workflow"
	end

	def workflow
		@company = CompanyCountry.find_by(web_address: request.subdomain, country_id: Country.find_by(locale: I18n.locale.to_s)) ? CompanyCountry.find_by(web_address: request.subdomain, country_id: Country.find_by(locale: I18n.locale.to_s)).company : nil
		if @company.nil?
			@company = CompanyCountry.find_by(web_address: request.subdomain.gsub(/www\./i, ''), country_id: Country.find_by(locale: I18n.locale.to_s)) ? CompanyCountry.find_by(web_address: request.subdomain.gsub(/www\./i, ''), country_id: Country.find_by(locale: I18n.locale.to_s)).company : nil
			if @company.nil?
				flash[:alert] = "No existe la compañia buscada."

				host = request.host_with_port
				domain = host[host.index(request.domain)..host.length]

				redirect_to root_url(:host => domain)
				return
			end
		end

		unless @company.company_setting.activate_workflow && @company.active
			flash[:alert] = "Lo sentimos, el mini-sitio que estás buscando no se encuentra disponible."

			host = request.host_with_port
			domain = host[host.index(request.domain)..host.length]

			redirect_to root_url(:host => domain)
			return
		end


		# => Domain parser
		host = request.host_with_port
		@url = @company.company_countries.find_by(country_id: Country.find_by(locale: I18n.locale.to_s)).web_address + '.' + host[host.index(request.domain)..host.length]

		if Location.where(:id => params[:local]).count > 0
			@location = Location.find(params[:local])
			@selectedLocation = @location
		else
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return
		end

		@online_payment_capable = @company.company_setting.online_payment_capable
		@promo_offerer_capable = @company.company_setting.promo_offerer_capable

		if mobile_request?
			company_setting = @company.company_setting
			now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
			@before_now = (now + company_setting.before_booking / 24.0).rfc2822
			@after_now = (now + company_setting.after_booking * 30).rfc2822
		end

		render layout: 'workflow'
	end

	##### Workflow - Mobile #####
	def select_hour

		if params[:location].blank?
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return

		elsif params[:serviceStaff].blank? or params[:datepicker].blank?
			flash[:alert] = "Error ingresando los datos."
			redirect_to workflow_path(:local => params[:location])
			return
		end

		@mandatory_discount = false
		@is_session_booking = false

		mobile_hours
		render layout: 'workflow'

		rescue ActionView::MissingTemplate => e
			redirect_to :action => "overview"
			return

	end

	def select_promo_hour

		if params[:location].blank?
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return

		elsif params[:serviceStaff].blank? or params[:datepicker].blank?
			flash[:alert] = "Error ingresando los datos."
			redirect_to workflow_path(:local => params[:location])
			return
		end

		@mandatory_discount = true
		@is_session_booking = false

		mobile_hours
		render layout: 'workflow'

		rescue ActionView::MissingTemplate => e
			redirect_to :action => "overview"
			return

	end

	def select_session_hour

		if params[:location].blank?
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return

		elsif params[:serviceStaff].blank? or params[:datepicker].blank?
			flash[:alert] = "Error ingresando los datos."
			redirect_to workflow_path(:local => params[:location])
			return
		end

		@booking = Booking.find(params[:booking_id])

		@mandatory_discount = false
		@is_session_booking = true

		mobile_hours

		respond_to do |format|
	      format.html { render :partial => 'select_session_hour' }
	      format.json { render json: @available_time }
	    end

	end



	def user_data
		if params[:location].blank?
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return
		elsif params[:service].blank? or params[:staff].blank? or params[:start].blank? or params[:end].blank? or params[:time_discount].blank? or params[:discount].blank? or params[:service_promo_id].blank? or params[:origin].blank? or params[:provider_lock].blank?
			flash[:alert] = "Error ingresando los datos."
			redirect_to workflow_path(:local => params[:location])
			return
		end
		@location = Location.find(params[:location])
		@company = @location.company
		@service = Service.find(params[:service])
		@provider = ServiceProvider.find(params[:staff])
		@start = params[:start]
		@end = params[:end]
		@origin = params[:origin]
		@lock = params[:provider_lock]

		@has_time_discount = false
		if params[:has_time_discount] && (params[:has_time_discount] == true || params[:has_time_discount] == "true")
			@has_time_discount = true
		end
		@time_discount = params[:time_discount]
		@has_discount = false
		if params[:has_discount] && (params[:has_discount] == true || params[:has_discount] == "true")
			@has_discount = true
		end
		@discount = params[:discount]

		@online_payable = false
		@is_time_discount = false
		@must_be_paid_online = false
		@hour_discount = 0

		logger.debug "service online_payable: " + @service.online_payable.to_s
		logger.debug "online_payment_capable: " + @company.company_setting.online_payment_capable.to_s
		logger.debug "allows_online_payment: " + @company.company_setting.allows_online_payment.to_s

		if @service.online_payable && @company.company_setting.online_payment_capable && @company.company_setting.allows_online_payment
			@online_payable = true
		end

		if @has_time_discount || @has_discount

			@online_payable = true
			@must_be_paid_online = true
			@has_discount = true

			if @has_time_discount
				@is_time_discount = true
				@hour_discount = @time_discount.to_f
			else
				@hour_discount = @discount.to_f
			end

		end

		logger.debug "online_payable" + @online_payable.to_s

		@service_promo_id = params[:service_promo_id]

		render layout: 'workflow'
		rescue ActionView::MissingTemplate => e
			redirect_to :action => "overview"
	end

	def add_company
		if current_user.company_id
			redirect_to dashboard_path
			return
		end
		@company = Company.new
		@banks = Bank.all
		render :layout => 'login'
	end

	def check_company_web_address
		@company_country = CompanyCountry.find_by(web_address: params[:web_address], country_id: params[:country_id])
		render :json => @company_country.nil?
	end

	def get_link
		@web_address = current_user.company.company_countries.find_by(country_id: Country.find_by(locale: I18n.locale.to_s)).web_address
	end

	def inventory

		if current_user.role_id != Role.find_by_name("Administrador General").id
			errors = ['No tienes suficientes privilegios para ver esta página.']
			format.html { redirect_to products_path, alert: 'No tienes suficientes privilegios para ver esta página.' }
        	format.json { render :json => { :errors => errors }, :status => 422 }
        	return
		end

		@company = current_user.company
		@products = []

		if params[:category] != "0" && params[:brand] != "0" && params[:display] != "0"
			@products = @company.products.where(:product_category_id => params[:category], :product_brand_id => params[:brand], :product_display_id => params[:display]).order(:product_category_id, :product_brand_id)
		elsif params[:category] != "0" && params[:brand] != "0" && params[:display] == "0"
			@products = @company.products.where(:product_category_id => params[:category], :product_brand_id => params[:brand]).order(:product_category_id, :product_brand_id)
		elsif params[:category] != "0" && params[:brand] == "0" && params[:display] != "0"
			@products = @company.products.where(:product_category_id => params[:category], :product_display_id => params[:display]).order(:product_category_id, :product_brand_id)
		elsif params[:category] != "0" && params[:brand] == "0" && params[:display] == "0"
			@products = @company.products.where(:product_category_id => params[:category]).order(:product_category_id, :product_brand_id)
		elsif params[:category] == "0" && params[:brand] != "0" && params[:display] != "0"
			@products = @company.products.where(:product_brand_id => params[:brand], :product_display_id => params[:display]).order(:product_category_id, :product_brand_id)
		elsif params[:category] == "0" && params[:brand] != "0" && params[:display] == "0"
			@products = @company.products.where(:product_brand_id => params[:brand]).order(:product_category_id, :product_brand_id)
		elsif params[:category] == "0" && params[:brand] == "0" && params[:display] != "0"
			@products = @company.products.where(:product_display_id => params[:display]).order(:product_category_id, :product_brand_id)
		else
			@products = @company.products.order(:product_category_id, :product_brand_id)
		end

		logger.info @products.inspect

	    respond_to do |format|
	      format.html { render :partial => 'inventory' }
	      format.json { render :json => @products }
	    end

	end

	def stock_alarm_form

		if current_user.role_id != Role.find_by_name("Administrador General").id
			errors = ['No tienes suficientes privilegios para ver esta página.']
			format.html { redirect_to products_path, alert: 'No tienes suficientes privilegios para ver esta página.' }
        	format.json { render :json => { :errors => errors }, :status => 422 }
        	return
		end
		
		@stock_alarm_settings = StockAlarmSetting.where(location_id: current_user.company.locations.where(:active => true).pluck(:id))
		respond_to do |format|
	      format.html { render :partial => 'stock_alarm_form' }
	      format.json { render :json => @locations }
	    end
	end

	def get_cashiers_by_code
		@cashier = Cashier.find_by_code(params[:cashier_code])
		render :json => @cashier
	end

	private

		#Common method to obtain available hours
		def mobile_hours

		    require 'date'

		    local = Location.find(params[:location])
		    company_setting = local.company.company_setting
		    cancelled_id = Status.find_by(name: 'Cancelado').id
		    serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
		    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
		    session_booking = nil

		    #if params[:session_booking_id] && params[:session_booking_id] != ""
		    #  session_booking = SessionBooking.find(params[:session_booking_id])
		    #end

		    if @is_session_booking
		    	session_booking = @booking.session_booking
		    end


		    if params[:datepicker] and params[:datepicker] != ""
		      if params[:datepicker].to_datetime > now
		        now = params[:datepicker].to_datetime
		      end
		    end

		    date = now
		    @date = Date.parse(params[:datepicker])

		    #logger.debug "now: " + now.to_s

		    days_ids = [1,2,3,4,5,6,7]
		    index = days_ids.find_index(now.cwday)
		    ordered_days = days_ids[index, days_ids.length] + days_ids[0, index]

		    book_index = 0
		    book_summaries = []

		    total_hours_array = []

		    loop_times = 0

		    max_time_diff = 0

		    #Save first service and it's providers for later use

		    first_service = Service.find(serviceStaff[0][:service])
		    first_providers = []
		    if serviceStaff[0][:provider] != "0"
		      first_providers << ServiceProvider.find(serviceStaff[0][:provider])
		    else
		      first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(:order, :public_name)
		    end

		    #Look for services and providers and save them for later use.
		    #Also, save total services duration

		    total_services_duration = 0

		    #False if last tried block allocation failed.
		    #Used for searching gaps. They should be looked for only if last block culd be allocated,
		    #because if not, then there isn't anyway that coming back in time cause correct allocation.
		    last_check = false

		    #Checks if the block being allocated is from a gap
		    is_gap_hour = false

		    #Holds current_gap to sum a day's total gap and adjust calendar's height
		    current_gap = 0

		    services_arr = []
		    providers_arr = []
		    for i in 0..serviceStaff.length-1
		      services_arr[i] = Service.find(serviceStaff[i][:service])
		      total_services_duration += services_arr[i].duration
		      if serviceStaff[i][:provider] != "0"
		        providers_arr[i] = []
		        providers_arr[i] << ServiceProvider.find(serviceStaff[i][:provider])
		      else
		        providers_arr[i] = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true)
		      end
		    end

		    #providers_arr = []
		    #for i
		    hours_array = []

		    after_date = DateTime.now + company_setting.after_booking.months

		    day = now.cwday
			dtp = local.location_times.where(day_id: day).order(:open).first

			if dtp.nil?
				if serviceStaff[0][:provider] == "0"
			    	@lock = false
			    else
			    	@lock = true
			    end

			    @lock
			    @company = local.company
			    @location = local
			    @serviceStaff = serviceStaff
			    @date = Date.parse(params[:datepicker])
			    @service = Service.find(serviceStaff[0][:service])

			    @available_time = hours_array
			    @bookSummaries = book_summaries
				return
			end

			dateTimePointer = dtp.open

			dateTimePointer = DateTime.new(now.year, now.mon, now.mday, dateTimePointer.hour, dateTimePointer.min)
			day_open_time = dateTimePointer

			dateTimePointerEnd = dateTimePointer


			if now > after_date
				if serviceStaff[0][:provider] == "0"
			    	@lock = false
			    else
			    	@lock = true
			    end

			    @lock
			    @company = local.company
			    @location = local
			    @serviceStaff = serviceStaff
			    @date = Date.parse(params[:datepicker])
			    @service = Service.find(serviceStaff[0][:service])

			    @available_time = hours_array
			    @bookSummaries = book_summaries
				return
			end


			day_close = local.location_times.where(day_id: day).order(:close).first.close
			limit_date = DateTime.new(now.year, now.mon, now.mday, day_close.hour, day_close.min)

			while (dateTimePointer < limit_date)

				serviceStaffPos = 0
				bookings = []

				while serviceStaffPos < serviceStaff.length and (dateTimePointer < limit_date)

				  service_valid = false
				  service = services_arr[serviceStaffPos]

				  #Get providers min
				  min_pt = ProviderTime.where(:service_provider_id => ServiceProvider.where(active: true, online_booking: true, :location_id => local.id, :id => ServiceStaff.where(:service_id => service.id).pluck(:service_provider_id)).pluck(:id)).where(day_id: day).order(:open).first

				  if !min_pt.nil? && min_pt.open.strftime("%H:%M") > dateTimePointer.strftime("%H:%M")
				    dateTimePointer = min_pt.open
				    dateTimePointer = DateTime.new(now.year, now.mon, now.mday, dateTimePointer.hour, dateTimePointer.min)
				    day_open_time = dateTimePointer
				  end

				  #To deattach continous services, just delete the serviceStaffPos condition

				  if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization && last_check
		            dateTimePointer = dateTimePointer - total_services_duration.minutes + first_service.company.company_setting.calendar_duration.minutes
		          end

				  if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization
				    #Calculate offset
				    offset_diff = (dateTimePointer-day_open_time)*24*60
				    offset_rem = offset_diff % first_service.company.company_setting.calendar_duration
				    if offset_rem != 0
				      dateTimePointer = dateTimePointer + (first_service.company.company_setting.calendar_duration - offset_rem).minutes
				    end
				  end

				  #Find next service block starting from dateTimePointer
				  service_sum = service.duration.minutes

				  minHour = now
				  #logger.debug "min_hours: " + minHour.to_s
				  if !params[:admin] && minHour <= DateTime.now
				    minHour += company_setting.before_booking.hours
				  end
				  if dateTimePointer >= minHour
				    service_valid = true
				  end


				  if service_valid
				    service_valid = false
				    local.location_times.where(day_id: dateTimePointer.cwday).each do |times|
				      location_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.open.hour, times.open.min)
				      location_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.close.hour, times.close.min)

				      if location_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= location_close
				        service_valid = true
				        break
				      end
				    end
				  end

				  # Horario dentro del horario del provider
					if service_valid
						providers = []
						if serviceStaff[serviceStaffPos][:provider] != "0"
						  providers = providers_arr[serviceStaffPos]
						else

						  #Check if providers have same day open
						  #If they do, choose the one with less ocupations to start with
						  #If they don't, choose the one that starts earlier.
						  if service.check_providers_day_times(dateTimePointer)

						    providers = providers_arr[serviceStaffPos].order(:order, :public_name).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }

						  else

						    providers = providers_arr[serviceStaffPos].order(:order, :public_name).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }
						  end



						end

						providers.each do |provider|

						  provider_min_pt = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first
						  if !provider_min_pt.nil? && dateTimePointer.strftime("%H:%M") < provider_min_pt.open.strftime("%H:%M")
						    dateTimePointer = provider_min_pt.open
						    dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
						  end

						  service_valid = false

						  #Check directly on query instead of looping through

						  provider.provider_times.where(day_id: dateTimePointer.cwday).each do |provider_time|
						    provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
						    provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

						    if provider_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= provider_close
						      service_valid = true
						      break
						    end
						  end

						  # Provider breaks
						  if service_valid

						    if provider.provider_breaks.where.not('(provider_breaks.end <= ? or ? <= provider_breaks.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
						      service_valid = false
						    end

						  end

						  # Cross Booking
						  if service_valid

						    if !service.group_service
						      if Booking.where(service_provider_id: provider.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
						        service_valid = false
						      end
						    else
						      if Booking.where(service_provider_id: provider.id, service_id: service.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count >= service.capacity
						        service_valid = false
						      end
						    end

						  end

						  # Recursos
						  if service_valid and service.resources.count > 0
						    service.resources.each do |resource|
						      if !local.resource_locations.pluck(:resource_id).include?(resource.id)
						        service_valid = false
						        break
						      end
						      used_resource = 0
						      group_services = []
						      pointerEnd = dateTimePointer+service.duration.minutes
						      local.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
						        if location_booking.status_id != cancelled_id && !(pointerEnd <= location_booking.start.to_datetime || location_booking.end.to_datetime <= dateTimePointer)
						          if location_booking.service.resources.include?(resource)
						            if !location_booking.service.group_service
						              used_resource += 1
						            else
						              if location_booking.service != service || location_booking.service_provider != provider
						                group_services.push(location_booking.service_provider.id)
						              end
						            end
						          end
						        end
						      end
						      if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: local.id).first.quantity
						        service_valid = false
						        break
						      end
						    end
						  end

						  if service_valid

						    book_sessions_amount = 0
						    if service.has_sessions
						      book_sessions_amount = service.sessions_amount
						    end

						    bookings << {
								:service => service.id,
								:provider => provider.id,
								:start => dateTimePointer,
								:end => dateTimePointer + service.duration.minutes,
								:service_name => service.name,
								:provider_name => provider.public_name,
								:provider_lock => serviceStaff[serviceStaffPos][:provider] != "0",
								:provider_id => provider.id,
								:price => service.price,
								:online_payable => service.online_payable,
								:has_discount => service.has_discount,
								:discount => service.discount,
								:show_price => service.show_price,
								:has_time_discount => service.has_time_discount,
								:has_sessions => service.has_sessions,
								:sessions_amount => book_sessions_amount,
								:must_be_paid_online => service.must_be_paid_online
				            }

						    if !service.online_payable || !service.company.company_setting.online_payment_capable
						    	bookings.last[:has_discount] = false
								bookings.last[:has_time_discount] = false
								bookings.last[:discount] = 0
								bookings.last[:time_discount] = 0
						    elsif !service.company.company_setting.promo_offerer_capable
								bookings.last[:has_time_discount] = false
								bookings.last[:time_discount] = 0
						    end

						    if service.has_time_discount && service.online_payable && service.company.company_setting.online_payment_capable && service.company.company_setting.promo_offerer_capable && service.time_promo_active

						      promo = Promo.where(:day_id => now.cwday, :service_promo_id => service.active_service_promo_id, :location_id => local.id).first

						      if !session_booking.nil? && !session_booking.service_promo_id.nil?
						        promo = Promo.where(:day_id => now.cwday, :service_promo_id => session_booking.service_promo_id, :location_id => local.id).first
						      end

						      if !promo.nil?

						        service_promo = ServicePromo.find(service.active_service_promo_id)

						        #Check if there is a limit for bookings, and if there are any left
						        if service_promo.max_bookings > 0 || !service_promo.limit_booking

						          #Check if the promo is still active, and if the booking ends before the limit date

						          if bookings.last[:end].to_datetime < service_promo.book_limit_date && DateTime.now < service_promo.finish_date

						            if !(service_promo.morning_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.morning_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

						              bookings.last[:time_discount] = promo.morning_discount

						            elsif !(service_promo.afternoon_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.afternoon_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

						              bookings.last[:time_discount] = promo.afternoon_discount

						            elsif !(service_promo.night_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.night_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

						              bookings.last[:time_discount] = promo.night_discount

						            else

						              bookings.last[:time_discount] = 0

						            end
						          else
						            bookings.last[:time_discount] = 0
						          end
						        else
						          bookings.last[:time_discount] = 0
						        end

						      else

						        bookings.last[:time_discount] = 0

						      end

						    else

						      bookings.last[:time_discount] = 0

						    end

						    if service.active_service_promo_id.nil?
						      bookings.last[:service_promo_id] = "0"
						    else
						      bookings.last[:service_promo_id] = service.active_service_promo_id
						    end

						    serviceStaffPos += 1

						    if first_service.company.company_setting.allows_optimization
						      if dateTimePointer < provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
						        dateTimePointer = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
						      else
						        dateTimePointer += service.duration.minutes
						      end
						    else
						      dateTimePointer = dateTimePointer + service.duration.minutes
						    end

						    if serviceStaffPos == serviceStaff.count
						      last_check = true

						      #Sum to gap_hours the gap_amount and reset gap flag.
						      if is_gap_hour
						        is_gap_hour = false
						        current_gap = 0
						      end
						    end

						    break

						  end
						end
					end

				  	if !service_valid


					    #Reset gap_hour
					    is_gap_hour = false

					    #First, check if there's a gap. If so, back dateTimePointer to (blocking_start - total_duration)
					    #This way, you can give two options when there are gaps.

					    #Assume there is no gap
					    time_gap = 0

					    if first_service.company.company_setting.allows_optimization && last_check

					      if first_providers.count > 1

					        first_providers.each do |first_provider|

					          book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

					          break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

					          provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

					          if !provider_time_gap.nil?

					            provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

					            if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
					              gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
					              if gap_diff > time_gap
					                time_gap = gap_diff
					              end
					            end

					          end

					          if book_gaps.count > 0
					            gap_diff = (book_gaps.first.start - dateTimePointer)/60
					            if gap_diff != 0
					              if gap_diff > time_gap
					                time_gap = gap_diff
					              end
					            end
					          end

					          if break_gaps.count > 0
					            gap_diff = (break_gaps.first.start - dateTimePointer)/60
					            if gap_diff != 0
					              if gap_diff > time_gap
					                time_gap = gap_diff
					              end
					            end
					          end

					        end

					      else

					        #Get nearest blocking start and check the gap.
					        #Blocking can come from provider time day end.

					        first_provider = first_providers.first

					        book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

					        break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

					        provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

					        if !provider_time_gap.nil?

					          provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

					          if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
					            gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
					            if gap_diff > time_gap
					              time_gap = gap_diff
					            end
					          end

					        end

					        if book_gaps.count > 0
					          gap_diff = (book_gaps.first.start - dateTimePointer)/60
					          if gap_diff != 0
					            if gap_diff > time_gap
					              time_gap = gap_diff
					            end
					          end
					        end

					        if break_gaps.count > 0
					          gap_diff = (break_gaps.first.start - dateTimePointer)/60
					          if gap_diff != 0
					            if gap_diff > time_gap
					              time_gap = gap_diff
					            end
					          end
					        end

					      end

					    end

					    #Check for providers' bookings and breaks that include current dateTimePointer
					    #If any, jump to the nearest end
					    #Else, it's gotta be a resource issue or dtp is outside providers' time, so just add service duration as always
					    #Last part could be optimized to jump to the nearest open provider's time

					    #Time check must be an overlap of (dtp - dtp+service_duration) with booking/break (start - end)

					    smallest_diff = first_service.duration
					    #logger.debug "Defined smallest_diff: " + smallest_diff.to_s


					    #Only do this when there is no gap
					    if first_service.company.company_setting.allows_optimization && time_gap == 0

					      if first_providers.count > 1

					        first_providers.each do |first_provider|


					          book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')

					          if book_blockings.count > 0

					            book_diff = (book_blockings.first.end - dateTimePointer)/60
					            if book_diff < smallest_diff
					              smallest_diff = book_diff

					            end
					          else
					            break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')

					            if break_blockings.count > 0
					              break_diff = (break_blockings.first.end - dateTimePointer)/60
					              if break_diff < smallest_diff
					                smallest_diff = break_diff

					              end
					            end
					          end

					        end

					      else

					        first_provider = first_providers.first

					        book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')

					        if book_blockings.count > 0
					          book_diff = (book_blockings.first.end - dateTimePointer)/60
					          if book_diff < smallest_diff
					            smallest_diff = book_diff
					          end
					        else
					          break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')

					          if break_blockings.count > 0
					            break_diff = (break_blockings.first.end - dateTimePointer)/60
					            if break_diff < smallest_diff
					              smallest_diff = break_diff
					            end
					          end
					        end

					      end

					      if smallest_diff == 0
					        smallest_diff = first_service.duration
					      end

					    else

					      smallest_diff = first_service.company.company_setting.calendar_duration

					    end

					    if first_service.company.company_setting.allows_optimization && time_gap > 0
					      dateTimePointer = (dateTimePointer + time_gap.minutes) - total_services_duration.minutes
					      is_gap_hour = true
					      current_gap = time_gap
					    else
					      current_gap = 0
					      dateTimePointer += smallest_diff.minutes
					    end

					    serviceStaffPos = 0
					    bookings = []

					    last_check = false

					  end
					end

				if bookings.length == serviceStaff.length and (dateTimePointer <=> now + company_setting.after_booking.month) == -1

				  has_time_discount = false
				  bookings_group_discount = 0
				  bookings_group_total_price = 0
				  bookings_group_computed_price = 0

				  bookings.each do |b|
				    bookings_group_total_price = bookings_group_total_price + b[:price]
				    if (b[:has_time_discount] && b[:time_discount] > 0) || (b[:has_discount] && b[:discount] > 0)
				      has_time_discount = true
				      if b[:has_discount] && !b[:has_time_discount]
				        bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
				      elsif !b[:has_discount] && b[:has_time_discount]
				        bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
				      else
				        if b[:discount] > b[:time_discount]
				          bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
				        else
				          bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
				        end
				      end
				    else
				      bookings_group_computed_price = bookings_group_computed_price + b[:price]
				    end
				  end

				  if (bookings_group_total_price != 0)
				    bookings_group_discount = (100 - (bookings_group_computed_price/bookings_group_total_price)*100).round(1)
				  end

				  status = "available"

				  if has_time_discount
				    if session_booking.nil?
				      status = "discount"
				    end
				  end

				  hour_time_diff = ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f

				  if hour_time_diff > max_time_diff
				    max_time_diff = hour_time_diff
				  end

				  curr_promo_discount = 0

				  if bookings.length == 1
				    curr_promo_discount = bookings[0][:time_discount]
				  end

				  if @mandatory_discount

				    if has_time_discount

				    	hour = {
					  		:start => bookings[0][:start].strftime("%H:%M"),
					  		:end => bookings[bookings.length-1][:end].strftime("%H:%M")
						}

				      	new_hour = {
			                index: book_index,
			                date: @date,
			                full_date: I18n.l(bookings[0][:start].to_date, format: :day),
			                hour: hour,
			                bookings: bookings,
			                status: status,
			                start_block: bookings[0][:start].strftime("%H:%M"),
			                end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
			                available_provider: bookings[0][:provider_name],
			                provider: bookings[0][:provider_id],
			                promo_discount: curr_promo_discount.to_s,
			                has_time_discount: bookings[0][:has_time_discount],
			                has_discount: bookings[0][:has_discount],
			                time_discount: bookings[0][:time_discount],
			                discount: bookings[0][:discount],
			                time_diff: hour_time_diff,
			                has_sessions: bookings[0][:has_sessions],
			                sessions_amount: bookings[0][:sessions_amount],
			                group_discount: bookings_group_discount.to_s,
			                service_promo_id: bookings[0][:service_promo_id]
			            }

				      	book_index = book_index + 1
				      	book_summaries << new_hour

				      	if !hours_array.include?(new_hour)

					        hours_array << new_hour
					        total_hours_array << new_hour

					    end

				    end

				  else

				  	hour = {
				  		:start => bookings[0][:start].strftime("%H:%M"),
				  		:end => bookings[bookings.length-1][:end].strftime("%H:%M")
					}

				  	#I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs'

				    new_hour = {
						index: book_index,
						date: @date,
						full_date: I18n.l(bookings[0][:start].to_date, format: :day),
						hour: hour,
						bookings: bookings,
						status: status,
						start_block: bookings[0][:start].strftime("%H:%M"),
						end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
						available_provider: bookings[0][:provider_name],
						provider: bookings[0][:provider_id],
		                promo_discount: curr_promo_discount.to_s,
		                has_time_discount: bookings[0][:has_time_discount],
		                has_discount: bookings[0][:has_discount],
		                time_discount: bookings[0][:time_discount],
			            discount: bookings[0][:discount],
		                time_diff: hour_time_diff,
		                has_sessions: bookings[0][:has_sessions],
		                sessions_amount: bookings[0][:sessions_amount],
		                group_discount: bookings_group_discount.to_s,
		                service_promo_id: bookings[0][:service_promo_id]
		            }

				    book_index = book_index + 1
				    book_summaries << new_hour

				    should_add = true

				    if !session_booking.nil?

				      if !session_booking.service_promo_id.nil? && session_booking.max_discount != 0
				        if new_hour[:group_discount].to_f < session_booking.max_discount.to_f
				          should_add = false
				        end
				      end

				    end

				    if params[:edit] && status == 'discount'
				      should_add = false
				    end

				    if should_add
				      if !hours_array.include?(new_hour)

				        hours_array << new_hour
				        total_hours_array << new_hour

				      end
				    end

				  end

				end

			end

			if serviceStaff[0][:provider] == "0"
		    	@lock = false
		    else
		    	@lock = true
		    end

		    @lock
		    @company = local.company
		    @location = local
		    @serviceStaff = serviceStaff
		    @date = Date.parse(params[:datepicker])
		    @service = Service.find(serviceStaff[0][:service])

		    @available_time = hours_array
		    @bookSummaries = book_summaries

		    logger.debug @available_time.inspect

		    @available_time

		end

		# Use callbacks to share common setup or constraints between actions.
		def set_company
			@company = Company.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def company_params
			params.require(:company).permit(:name, :plan_id, :logo, :remove_logo, :payment_status_id, :pay_due, :web_address, :description, :cancellation_policy, :months_active_left, :due_amount, :due_date, :active, :show_in_home, :country_id, company_setting_attributes: [:before_booking, :after_booking, :allows_online_payment, :account_number, :company_rut, :account_name, :account_type, :bank_id], economic_sector_ids: [], company_countries_attributes: [:id, :country_id, :web_address, :active])
		end
end
