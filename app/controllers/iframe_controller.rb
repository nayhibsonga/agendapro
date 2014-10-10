class IframeController < ApplicationController
	after_action :allow_iframe

	def sampler
		render layout: false
	end

	def overview
		@company = Company.find(params[:company_id])

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
		render layout: "iframe"
	end

	def workflow
		@location = Location.find(params[:location_id])
		@company = @location.company
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

		if mobile_request?
			company_setting = @company.company_setting
			now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
			@before_now = (now + company_setting.before_booking / 24.0).rfc2822
			@after_now = (now + company_setting.after_booking * 30).rfc2822
		end
		
		render layout: "iframe"
	end

	def book_service
		@location_id = params[:location]
		@company = Location.find(params[:location]).company
		if params[:address] && !params[:address].empty?
		  params[:comment] += ' - Dirección del cliente (donde se debe realizar el servicio): ' + params[:address]
		end
		if @company.company_setting.client_exclusive
		  if Client.where(identification_number: params[:identification_number], company_id: @company).count > 0
		    client = Client.where(identification_number: params[:identification_number], company_id: @company).first
		    client.first_name = params[:firstName]
		    client.last_name = params[:lastName]
		    client.email = params[:email]
		    client.phone = params[:phone]
		    client.save
		  else
		    flash[:alert] = "No estás ingresado como cliente o no puedes reservar. Porfavor comunícate con la empresa proveedora del servicio."
		    @errors = ["No estás ingresado como cliente"]
		    host = request.host_with_port
		    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]
		    render layout: "workflow"
		    return
		  end
		else
		  if Client.where(email: params[:email], company_id: @company).count > 0
		    client = Client.where(email: params[:email], company_id: @company).first
		    client.first_name = params[:firstName]
		    client.last_name = params[:lastName]
		    client.phone = params[:phone]
		    client.save
		  else
		    client = Client.new(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], company_id: @company.id)
		    client.save
		  end
		end
		if user_signed_in?
		  @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, client_id: client.id, user_id: current_user.id, web_origin: params[:origin], provider_lock: params[:provider_lock])
		else
		  if User.find_by_email(params[:email])
		    @user = User.find_by_email(params[:email])
		    @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, client_id: client.id, user_id: @user.id, web_origin: params[:origin], provider_lock: params[:provider_lock])
		  else
		    @booking = Booking.new(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], service_id: params[:service], location_id: params[:location], status_id: Status.find_by(name: 'Reservado').id, client_id: client.id, web_origin: params[:origin], provider_lock: params[:provider_lock])
		  end
		end
		@booking.price = Service.find(params[:service]).price
		if @booking.save
		  flash[:notice] = "Reserva realizada exitosamente."

		  # BookingMailer.book_service_mail(@booking)
		else
		  flash[:alert] = "Hubo un error guardando los datos de tu reserva. Inténtalo nuevamente."
		  @errors = @booking.errors.full_messages
		end

		# => Domain parser
		host = request.host_with_port
		@url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

		render layout: "iframe"
	end

	private

	def allow_iframe
		response.headers.except! 'X-Frame-Options'
	end
end
