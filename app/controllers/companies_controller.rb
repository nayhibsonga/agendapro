class CompaniesController < ApplicationController
  before_action :verify_is_active, only: [:overview, :workflow]
	before_action :set_company, only: [:show, :edit, :update, :destroy, :edit_payment]
	before_action :authenticate_user!, except: [:new, :overview, :workflow, :check_company_web_address, :select_hour, :user_data]
	before_action :quick_add, except: [:new, :overview, :workflow, :add_company, :check_company_web_address, :select_hour, :user_data]
	before_action :verify_is_super_admin, only: [:index, :edit_payment, :new, :edit, :manage, :manage_company, :new_payment, :add_payment, :update_company, :get_year_incomes, :incomes, :locations, :monthly_locations, :deactivate_company]

	layout "admin", except: [:show, :overview, :workflow, :add_company, :select_hour, :user_data]
	load_and_authorize_resource


	# GET /companies
	# GET /companies.json
	def index
		@companies = Company.all.order(:name)
	end

	#SuperAdmin
	#Manage companies payments.
	def manage
		@companies = Company.all.order(:name)
		@active_companies = Company.where(:payment_status_id => PaymentStatus.find_by_name('Activo').id).order(:name)
		@trial_companies = Company.where(:payment_status_id => PaymentStatus.find_by_name('Trial').id).order(:name)
		@late_companies = Company.where(:payment_status_id => PaymentStatus.find_by_name('Vencido').id).order(:name)
		@blocked_companies = Company.where(:payment_status_id => PaymentStatus.find_by_name('Bloqueado').id).order(:name)
		@inactive_companies = Company.where(:payment_status_id => PaymentStatus.find_by_name('Inactivo').id).order(:name)
		@issued_companies = Company.where(:payment_status_id => PaymentStatus.find_by_name('Emitido').id).order(:name)
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
		@company.plan_id = params[:new_plan_id]
		if params[:new_due_amount].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			@company.due_amount = params[:new_due_amount]
		end
		if params[:new_months_active_left].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			@company.months_active_left = params[:new_months_active_left]
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
			company.plan = Plan.where(custom: false, locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:price).first
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
				format.html { redirect_to edit_company_setting_path(@company.company_setting), notice: 'Empresa actualizada exitosamente.' }
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
			@company = Company.find_by(web_address: request.subdomain.gsub(/www\./i, ''))
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
		@locations = Location.where(:active => true, online_booking: true).where(company_id: @company.id).where(id: ServiceProvider.where(active: true, company_id: @company.id, online_booking: true).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: @company.id, online_booking: true).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(order: :asc)

		# => Domain parser
		host = request.host_with_port
		@url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

		#Selected local from fase II
		if(params[:local])
			@selectedLocal = params[:local]
			if Location.where(:id => @selectedLocal).count > 0
				@selectedLocation = Location.find(@selectedLocal)
			else
				flash[:alert] = "Lo sentimos, el local ingresado no existe."

				#host = request.host_with_port
				#domain = host[host.index(request.domain)..host.length]

				#redirect_to root_url(:host => domain)
				#return
			end
		end

		if mobile_request?
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
		@company = Company.find_by(web_address: request.subdomain)
		if @company.nil?
			@company = Company.find_by(web_address: request.subdomain.gsub(/www\./i, ''))
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
		@url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

		if Location.where(:id => params[:local]).count > 0
			@location = Location.find(params[:local])
			@selectedLocation = @location
		else
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return
		end

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
		@service = Service.find(params[:service])
		service_duration = @service.duration
		@date = Date.parse(params[:datepicker])
		@location = Location.find(params[:location])
		company_setting = CompanySetting.find(Company.find(@location.company_id).company_setting)
		cancelled_id = Status.find_by(name: 'Cancelado').id
		if params[:provider] == "0"
			# Data
			provider_breaks = ProviderBreak.where(:service_provider_id => @location.service_providers.pluck(:id))
			location_times_first = @location.location_times.order(:open).first
			location_times_final = @location.location_times.order(close: :desc).first

			# Block Hour
			# {
			#   status: 'available/occupied/empty/past',
			#   hour: {
			#     start: '10:00',
			#     end: '10:30',
			#     provider: ''
			#   }
			# }

			@available_time = Array.new

			# Variable Data
			day = @date.cwday
			ordered_providers = ServiceProvider.where(id: @service.service_providers.pluck(:id), location_id: @location.id, active: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(@date) }
			location_times = @location.location_times.where(day_id: day).order(:open)

			if location_times.length > 0

				location_times_first_open = location_times_first.open
				location_times_final_close = location_times_final.close

				location_times_first_open_start = location_times_first_open

				while (location_times_first_open_start <=> location_times_final_close) < 0 do

					location_times_first_open_end = location_times_first_open_start + service_duration.minutes

					status = 'empty'
					hour = {
					  :start => '',
					  :end => ''
					}

					open_hour = location_times_first_open_start.hour
					open_min = location_times_first_open_start.min
					start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

					next_open_hour = location_times_first_open_end.hour
					next_open_min = location_times_first_open_end.min
					end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


					start_time_block = DateTime.new(@date.year, @date.mon, @date.mday, open_hour, open_min)
					end_time_block = DateTime.new(@date.year, @date.mon, @date.mday, next_open_hour, next_open_min)
					now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
					before_now = start_time_block - company_setting.before_booking / 24.0
					after_now = now + company_setting.after_booking * 30

					available_provider = ''
					ordered_providers.each do |provider|
					  provider_time_valid = false
					  provider_free = true
					  provider.provider_times.where(day_id: day).each do |provider_time|
					    if (provider_time.open - location_times_first_open_end)*(location_times_first_open_start - provider_time.close) > 0
					    	if provider_time.open <= location_times_first_open_start && provider_time.close >= location_times_first_open_end
	            		provider_time_valid = true
				      	end
					    end
					    break if provider_time_valid
					  end
					  if provider_time_valid
					    if (before_now <=> now) < 1
					      status = 'past'
					    elsif (after_now <=> end_time_block) < 1
					      status = 'past'
					    else
					      status = 'occupied'
					      Booking.where(:service_provider_id => provider.id, :start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |provider_booking|
					        unless provider_booking.status_id == cancelled_id
					          if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
					            if !@service.group_service || @service.id != provider_booking.service_id
					              provider_free = false
					              break
					            elsif @service.group_service && @service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => @service.id, :start => start_time_block).count >= @service.capacity
					              provider_free = false
					              break
					            end
					          end
					        end
					      end
					      if @service.resources.count > 0
					        @service.resources.each do |resource|
					          if !@location.resource_locations.pluck(:resource_id).include?(resource.id)
					            provider_free = false
					            break
					          end
					          used_resource = 0
					          group_services = []
					          @location.bookings.where(:start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |location_booking|
					            if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
					              if location_booking.service.resources.include?(resource)
					                if !location_booking.service.group_service
					                  used_resource += 1
					                else
					                  if location_booking.service != @service || location_booking.service_provider != provider
					                    group_services.push(location_booking.service_provider.id)
					                  end
					                end
					              end
					            end
					          end
					          if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: @location.id).first.quantity
					            provider_free = false
					            break
					          end
					        end
					      end
					      ProviderBreak.where(:service_provider_id => provider.id).each do |provider_break|
					        if (provider_break.start.to_datetime - end_time_block)*(start_time_block - provider_break.end.to_datetime) > 0
					          provider_free = false
					        end
					        break if !provider_free
					      end
					      if provider_free
					        status = 'available'
					        available_provider = provider.id
					      end
					    end
					    break if ['past','available'].include? status
					  end
					end

					if ['past','available','occupied'].include? status
					  hour = {
					    :start => start_block,
					    :end => end_block,
					  }
					end

					block_hour = Hash.new

					block_hour[:date] = @date
					block_hour[:hour] = hour
					block_hour[:provider] = available_provider

					@available_time << block_hour if status == 'available'
					location_times_first_open_start = location_times_first_open_start + service_duration.minutes
				end
			end

    	else

			# Data
			provider = ServiceProvider.find(params[:provider])
			provider_breaks = provider.provider_breaks
			provider_times_first = provider.provider_times.order(:open).first
			provider_times_final = provider.provider_times.order(close: :desc).first

			# Block Hour
			# {
			#   status: 'available/occupied/empty/past',
			#   hour: {
			#     start: '10:00',
			#     end: '10:30',
			#     provider: ''
			#   }
			# }

			@available_time = Array.new

			# Variable Data
			day = @date.cwday
			provider_times = provider.provider_times.where(day_id: day).order(:open)

			if provider_times.length > 0

				provider_times_first_open = provider_times_first.open
				provider_times_final_close = provider_times_final.close

				provider_times_first_open_start = provider_times_first_open

				time_offset = 0

				while (provider_times_first_open_start <=> provider_times_final_close) < 0 do

					provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes

					status = 'empty'
					hour = {
					  :start => '',
					  :end => ''
					}

					available_provider = ''
					provider_time_valid = false
					provider_free = true
					provider_times.each do |provider_time|
	          if (provider_time.open - provider_times_first_open_end)*(provider_times_first_open_start - provider_time.close) > 0
	            if provider_time.open > provider_times_first_open_start
	              time_offset += (provider_time.open - provider_times_first_open_start)/1.minutes
	              if time_offset < service_duration
	                provider_times_first_open_start = provider_time.open
	                provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes
	              end
	            end
	            if provider_time.open <= provider_times_first_open_start && provider_time.close >= provider_times_first_open_end
	              provider_time_valid = true
	            elsif provider_time.open <= provider_times_first_open_start
	              time_offset = time_offset % service_duration
	              provider_times_first_open_start -= time_offset.minutes
	              provider_times_first_open_end -= time_offset.minutes
	              time_offset = 0
	            else
	              provider_times_first_open_start -= time_offset.minutes
	              provider_times_first_open_end -= time_offset.minutes
	              time_offset = 0
	            end
	          end
	          break if provider_time_valid
	        end

					open_hour = provider_times_first_open_start.hour
					open_min = provider_times_first_open_start.min
					start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

					next_open_hour = provider_times_first_open_end.hour
					next_open_min = provider_times_first_open_end.min
					end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


					start_time_block = DateTime.new(@date.year, @date.mon, @date.mday, open_hour, open_min)
					end_time_block = DateTime.new(@date.year, @date.mon, @date.mday, next_open_hour, next_open_min)
					now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
					before_now = start_time_block - company_setting.before_booking / 24.0
					after_now = now + company_setting.after_booking * 30

					if provider_time_valid
					  if (before_now <=> now) < 1
					    status = 'past'
					  elsif (after_now <=> end_time_block) < 1
					    status = 'past'
					  else
					    status = 'occupied'
					    Booking.where(:service_provider_id => provider.id, :start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |provider_booking|
					      unless provider_booking.status_id == cancelled_id
					        if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
					          if !@service.group_service || @service.id != provider_booking.service_id
					            provider_free = false
					            break
					          elsif @service.group_service && @service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => @service.id, :start => start_time_block).count >= @service.capacity
					            provider_free = false
					            break
					          end
					        end
					      end
					    end
					    if @service.resources.count > 0
					      @service.resources.each do |resource|
					        if !@location.resource_locations.pluck(:resource_id).include?(resource.id)
					          provider_free = false
					          break
					        end
					        used_resource = 0
					        group_services = []
					        @location.bookings.where(:start => @date.to_time.beginning_of_day..@date.to_time.end_of_day).each do |location_booking|
					          if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
					            if location_booking.service.resources.include?(resource)
					              if !location_booking.service.group_service
					                used_resource += 1
					              else
					                if location_booking.service != @service || location_booking.service_provider != provider
					                  group_services.push(location_booking.service_provider.id)
					                end
					              end
					            end
					          end
					        end
					        if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: @location.id).first.quantity
					          provider_free = false
					          break
					        end
					      end
					    end
					    ProviderBreak.where(:service_provider_id => provider.id).order(:start).each do |provider_break|
					      if (provider_break.start.to_datetime - end_time_block)*(start_time_block - provider_break.end.to_datetime) > 0
					        provider_free = false
					      end
					      break if !provider_free
					    end

					    if provider_free
					      status = 'available'
					      available_provider = provider.id
					    end
					  end
					end

					if ['past','available','occupied'].include? status
					  hour = {
					    :start => start_block,
					    :end => end_block
					  }
					end

					block_hour = Hash.new

					block_hour[:date] = @date
					block_hour[:hour] = hour
					block_hour[:provider] = available_provider

					@available_time << block_hour if status == 'available'
					provider_times_first_open_start = provider_times_first_open_end
				end
			end
    	end

    if params[:provider] == "0"
    	@lock = false
    else
    	@lock = true
    end
    @lock
    @company = @location.company
    @available_time
		render layout: 'workflow'
	end

	def user_data

		@location = Location.find(params[:location])
		@company = @location.company
		@service = Service.find(params[:service])
		@provider = ServiceProvider.find(params[:staff])
		@start = params[:start]
		@end = params[:end]
		@origin = params[:origin]
		@lock = params[:provider_lock]

		render layout: 'workflow'
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
		begin
		@company = Company.find_by(:web_address => params[:user][:company_attributes][:web_address])
		rescue
			@company = Company.find_by(:web_address => params[:company][:web_address])
		end
		render :json => @company.nil?
	end

	def get_link
		@web_address = Company.find(current_user.company_id).web_address
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_company
			@company = Company.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def company_params
			params.require(:company).permit(:name, :plan_id, :logo, :remove_logo, :payment_status_id, :pay_due, :web_address, :description, :cancellation_policy, :months_active_left, :due_amount, :due_date, :active, company_setting_attributes: [:before_booking, :after_booking, :allows_online_payment, :account_number, :company_rut, :account_name, :account_type, :bank_id], economic_sector_ids: [])
		end
end
