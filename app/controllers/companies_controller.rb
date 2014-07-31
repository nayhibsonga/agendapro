class CompaniesController < ApplicationController
  before_action :verify_is_active, only: [:overview, :workflow]
	before_action :set_company, only: [:show, :edit, :update, :destroy]
	before_action :authenticate_user!, except: [:new, :overview, :workflow, :check_company_web_address, :select_hour, :user_data]
	before_action :quick_add, except: [:new, :overview, :workflow, :add_company, :check_company_web_address, :select_hour, :user_data]
	before_action :verify_is_super_admin, only: [:index]

	layout "admin", except: [:show, :overview, :workflow, :add_company, :select_hour, :user_data]
	load_and_authorize_resource


	# GET /companies
	# GET /companies.json
	def index
		@companies = Company.all.order(:name)
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
				format.html { redirect_to dashboard_path, notice: 'Empresa actualizada exitosamente.' }
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
		@locations = Location.where(:active => true).where(company_id: @company.id).where(id: ServiceProvider.where(active: true, company_id: @company.id).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: @company.id).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(order: :asc)

		# => Domain parser
		host = request.host_with_port
		@url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

		#Selected local from fase II
		@selectedLocal = params[:local]

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
		unless @company.company_setting.activate_workflow && @company.active
			flash[:alert] = "Lo sentimos, el mini-sitio que estás buscando no se encuentra disponible."

			host = request.host_with_port
			domain = host[host.index(request.domain)..host.length]

			redirect_to root_url(:host => domain)
			return
		end
		@location = Location.find(params[:local])

		# => Domain parser
		host = request.host_with_port
		@url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

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
		@location = Location.find(params[:local])
		@company = @location.company
		@service = Service.find(params[:services])
		@provider = ServiceProvider.find(params[:providers])

		# require 'date'

		# Data
		date = Date.parse(params[:datepicker])
		service_duration = @service.duration
		company_setting = @company.company_setting
		provider_breaks = ProviderBreak.where(:service_provider_id => @provider.id)

		# Block Hour
		# {
		#   status: 'available/occupied/empty/past',
		#   date: '2014-06-1',
		#   hour: {
		#     start: '10:00',
		#     end: '10:30'
		#   }
		# }
		@available_time = Array.new

		# Variable Data
		provider_times = @provider.provider_times.where(day_id: date.cwday).order(:open)
		bookings = @provider.bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).order(:start)

		cancelled_id = Status.find_by(name: 'Cancelado').id

		# Hour Blocks
		$i = 0
		$length = provider_times.length
		while $i < $length do
		  provider_time = provider_times[$i]
		  provider_time_open = provider_time.open
		  provider_time_close = provider_time.close

		  # => Available/Occupied Blocks
		  while (provider_time_open <=> provider_time_close) < 0 do
			block_hour = Hash.new

			# Tmp data
			open_hour = provider_time_open.hour
			open_min = provider_time_open.min

			start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

			provider_time_open += service_duration.minutes

			# Tmp data
			next_open_hour = provider_time_open.hour
			next_open_min = provider_time_open.min

			end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s

			# Block Hour
			hour = {
			  :start => start_block,
			  :end => end_block
			}

			# Status
			status = 'available'
			start_time_block = DateTime.new(date.year, date.mon, date.mday, open_hour, open_min)
			end_time_block = DateTime.new(date.year, date.mon, date.mday, next_open_hour, next_open_min)
			
			# Past hours
			now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
			before_now = start_time_block - company_setting.before_booking / 24.0
			after_now = now + company_setting.after_booking * 30

			provider_breaks.each do |provider_break|
			  break_start = DateTime.parse(provider_break.start.to_s)
			  break_end = DateTime.parse(provider_break.end.to_s)
			  if  (break_start - end_time_block) * (start_time_block - break_end) > 0
				status = 'occupied'
			  end
			end
			if @service.resources.count > 0
              @service.resources.each do |resource|
                if !@location.resource_locations.pluck(:resource_id).include?(resource.id)
                  status = 'occupied'
                end
                used_resource = 0
                group_services = []
                @location.bookings.each do |location_booking|
                  booking_start = DateTime.parse(location_booking.start.to_s)
                  booking_end = DateTime.parse(location_booking.end.to_s)
                  if location_booking != cancelled_id && (booking_start - end_time_block) * (start_time_block - booking_end) > 0
                    if location_booking.service.resources.include?(resource)
                      if !location_booking.service.group_service
                        used_resource += 1
                      else
                        if location_booking.service != @service || location_booking.service_provider != booking.service_provider
                          group_services.push(location_booking.service_provider.id)
                        end
                      end   
                    end
                  end
                end
                if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: @location.id).first.quantity
                  status = 'occupied'
                end
              end
            end

			if (before_now <=> now) < 1
			  status = 'past'
			elsif (after_now <=> end_time_block) < 1
			  status = 'past'
			else
			  bookings.each do |booking|
				booking_start = DateTime.parse(booking.start.to_s)
				booking_end = DateTime.parse(booking.end.to_s)

				if (booking_start - end_time_block) * (start_time_block - booking_end) > 0 && booking.status_id != Status.find_by(name: 'Cancelado').id
				  if !@service.group_service || @service.id != booking.service_id
					status = 'occupied'
				  elsif @service.group_service && @service.id == booking.service_id && @provider.bookings.where(:service_id => @service.id, :start => booking.start).count >= @service.capacity
					status = 'occupied'
				  end
				end
			  end
			end

			block_hour[:date] = date
			block_hour[:hour] = hour

			@available_time << block_hour if status == 'available'
		  end

		  $i += 1
		end

		@available_time

		render layout: 'workflow'
	end

	def user_data
		@location = Location.find(params[:location])
		@company = @location.company
		@service = Service.find(params[:service])
		@provider = ServiceProvider.find(params[:provider])
		@start = params[:start]
		@end = params[:end]
		@origin = params[:origin]

		render layout: 'workflow'
	end

	def add_company
		if current_user.company_id
			redirect_to dashboard_path
			return
		end
		@company = Company.new
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
			params.require(:company).permit(:name, :economic_sector_id, :plan_id, :logo, :remove_logo, :payment_status_id, :pay_due, :web_address, :description, :cancellation_policy, company_setting_attributes: [:before_booking, :after_booking])
			#params.require(:company).permit(:name, :economic_sector_id, :plan_id, :logo, :payment_status_id, :pay_due, :web_address, :users_attributes[:id, :first_name, :last_name, :email, :phone, :user_name, :password, :role_id, :company_id])
		end
end
