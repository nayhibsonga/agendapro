class CompaniesController < ApplicationController
  before_action :verify_is_active, only: [:overview, :workflow]
	before_action :set_company, only: [:show, :edit, :update, :destroy, :edit_payment]
	before_action :authenticate_user!, except: [:new, :overview, :workflow, :check_company_web_address, :select_hour, :user_data]
	before_action :quick_add, except: [:new, :overview, :workflow, :add_company, :check_company_web_address, :select_hour, :user_data]
	before_action :verify_is_super_admin, only: [:index, :edit_payment]

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

	def edit_payment
	end

	# POST /companies
	# POST /companies.json
	def create
		@company = Company.new(company_params)
		@company.payment_status_id = PaymentStatus.find_by_name("Trial").id
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
		if params[:providers] == "0"
			# Data
			service = Service.find(params[:services])
			service_duration = service.duration
			date = Date.parse(params[:datepicker])
			local = Location.find(params[:local])
			company_setting = CompanySetting.find(Company.find(local.company_id).company_setting)
			provider_breaks = ProviderBreak.where(:service_provider_id => local.service_providers.pluck(:id))
			cancelled_id = Status.find_by(name: 'Cancelado').id
			location_times_first = local.location_times.order(:open).first
			location_times_final = local.location_times.order(close: :desc).first
			@service = service
	    	@location = local

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
			day = date.cwday
			ordered_providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true).order(:order).sort_by {|service_provider| service_provider.provider_booking_day_occupation(date) }
			location_times = local.location_times.where(day_id: day).order(:open)

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


				start_time_block = DateTime.new(date.year, date.mon, date.mday, open_hour, open_min)
				end_time_block = DateTime.new(date.year, date.mon, date.mday, next_open_hour, next_open_min)
				now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
				before_now = start_time_block - company_setting.before_booking / 24.0
				after_now = now + company_setting.after_booking * 30

				available_provider = ''
				ordered_providers.each do |provider|
				  provider_time_valid = false
				  provider_free = true
				  provider.provider_times.each do |provider_time|
				    if (provider_time.open - location_times_first_open_end)*(location_times_first_open_start - provider_time.close) > 0
				      provider_time_valid = true
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
				      Booking.where(:service_provider_id => provider.id, :start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |provider_booking|
				        unless provider_booking.status_id == cancelled_id
				          if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
				            if !service.group_service || service.id != provider_booking.service_id
				              provider_free = false
				              break
				            elsif service.group_service && service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => start_time_block).count >= service.capacity
				              provider_free = false
				              break
				            end
				          end
				        end
				      end
				      if service.resources.count > 0
				        service.resources.each do |resource|
				          if !local.resource_locations.pluck(:resource_id).include?(resource.id)
				            provider_free = false
				            break
				          end
				          used_resource = 0
				          group_services = []
				          local.bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |location_booking|
				            if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
				              puts "topa"
				              if location_booking.service.resources.include?(resource)
				                puts "incluye"
				                if !location_booking.service.group_service
				                  puts "recurso usado"
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

				block_hour[:date] = date
				block_hour[:hour] = hour
				block_hour[:provider] = available_provider

				@available_time << block_hour if status == 'available'
				location_times_first_open_start = location_times_first_open_start + service_duration.minutes
				end
			end

	    else

			# Data
			service = Service.find(params[:services])
			service_duration = service.duration
			date = Date.parse(params[:datepicker])
			local = Location.find(params[:local])
			company_setting = CompanySetting.find(Company.find(local.company_id).company_setting)
			provider = ServiceProvider.find(params[:providers])
			provider_breaks = provider.provider_breaks
			cancelled_id = Status.find_by(name: 'Cancelado').id
			provider_times_first = provider.provider_times.order(:open).first
			provider_times_final = provider.provider_times.order(close: :desc).first
			@service = service
	    	@location = local

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
			day = date.cwday
			provider_times = provider.provider_times.where(day_id: day).order(:open)

			if provider_times.length > 0

			provider_times_first_open = provider_times_first.open
			provider_times_final_close = provider_times_final.close

			provider_times_first_open_start = provider_times_first_open

			while (provider_times_first_open_start <=> provider_times_final_close) < 0 do

			provider_times_first_open_end = provider_times_first_open_start + service_duration.minutes

			status = 'empty'
			hour = {
			  :start => '',
			  :end => ''
			}

			open_hour = provider_times_first_open_start.hour
			open_min = provider_times_first_open_start.min
			start_block = (open_hour < 10 ? '0' : '') + open_hour.to_s + ':' + (open_min < 10 ? '0' : '') + open_min.to_s

			next_open_hour = provider_times_first_open_end.hour
			next_open_min = provider_times_first_open_end.min
			end_block = (next_open_hour < 10 ? '0' : '') + next_open_hour.to_s + ':' + (next_open_min < 10 ? '0' : '') + next_open_min.to_s


			start_time_block = DateTime.new(date.year, date.mon, date.mday, open_hour, open_min)
			end_time_block = DateTime.new(date.year, date.mon, date.mday, next_open_hour, next_open_min)
			now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
			before_now = start_time_block - company_setting.before_booking / 24.0
			after_now = now + company_setting.after_booking * 30

			available_provider = ''
			provider_time_valid = false
			provider_free = true
			provider.provider_times.each do |provider_time|
			  if (provider_time.open - provider_times_first_open_end)*(provider_times_first_open_start - provider_time.close) > 0
			    provider_time_valid = true
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
			    Booking.where(:service_provider_id => provider.id, :start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |provider_booking|
			      unless provider_booking.status_id == cancelled_id
			        if (provider_booking.start.to_datetime - end_time_block) * (start_time_block - provider_booking.end.to_datetime) > 0
			          if !service.group_service || service.id != provider_booking.service_id
			            provider_free = false
			            break
			          elsif service.group_service && service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => start_time_block).count >= service.capacity
			            provider_free = false
			            break
			          end
			        end
			      end
			    end
			    if service.resources.count > 0
			      service.resources.each do |resource|
			        if !local.resource_locations.pluck(:resource_id).include?(resource.id)
			          provider_free = false
			          break
			        end
			        used_resource = 0
			        group_services = []
			        local.bookings.where(:start => date.to_time.beginning_of_day..date.to_time.end_of_day).each do |location_booking|
			          if location_booking.status_id != cancelled_id && (location_booking.start.to_datetime - end_time_block) * (start_time_block - location_booking.end.to_datetime) > 0
			            puts "topa"
			            if location_booking.service.resources.include?(resource)
			              puts "incluye"
			              if !location_booking.service.group_service
			                puts "recurso usado"
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
			          provider_free = false
			          break
			        end
			      end
			    end
			    ProviderBreak.where(:service_provider_id => provider.id).order(:start).each do |provder_break|
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

			block_hour[:date] = date
			block_hour[:hour] = hour
			block_hour[:provider] = available_provider

			@available_time << block_hour if status == 'available'
			provider_times_first_open_start = provider_times_first_open_end
			end
			end
	    end
	    @company = @location.company
	    @service
	    @location
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
			params.require(:company).permit(:name, :economic_sector_id, :plan_id, :logo, :remove_logo, :payment_status_id, :pay_due, :web_address, :description, :cancellation_policy, :months_active_left, :due_amount, :due_date, :active, company_setting_attributes: [:before_booking, :after_booking])
			#params.require(:company).permit(:name, :economic_sector_id, :plan_id, :logo, :payment_status_id, :pay_due, :web_address, :users_attributes[:id, :first_name, :last_name, :email, :phone, :user_name, :password, :role_id, :company_id])
		end
end
