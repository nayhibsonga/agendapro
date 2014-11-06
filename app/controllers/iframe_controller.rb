class IframeController < ApplicationController
	after_action :allow_iframe
	skip_before_action :verify_authenticity_token

	def sampler
		render layout: false
	end

	def construction
		render layout: false
	end

	def facebook_setup
		if params[:fb_page_id]
			page_id = params[:fb_page_id]
			if FacebookPage.find_by_facebook_page_id(page_id)
				@facebook_page = FacebookPage.find_by_facebook_page_id(page_id)
			else
				@facebook_page = FacebookPage.new
				@facebook_page.facebook_page_id = params[:fb_page_id]
			end
		else
			redirect_to iframe_construction_path
			return
		end
		render layout: "iframe"
	end

	def facebook_submit
		@facebook_page = FacebookPage.find_by_facebook_page_id(params[:facebook_page][:facebook_page_id]) || FacebookPage.new
		@facebook_page.facebook_page_id = params[:facebook_page][:facebook_page_id]
		@facebook_page.company_id = params[:facebook_page][:company_id].to_i(30)/123456
		respond_to do |format|
			if @facebook_page.save
				format.html { redirect_to facebook_success_path, notice: 'Página configurada Correctamente.' }
			else
				format.html { render action: 'facebook_setup' }
			end
		end
	end

	def facebook_success
		render layout: "iframe"
	end

	def overview
		if params[:signed_request]
			app_secret = "4f46d0f4f4c36a03ead5ced6c0f0ff87"
			signed_request = FBGraph::Canvas.parse_signed_request(app_secret, params[:signed_request])
			@admin = signed_request["page"]["admin"]
			@page_id = signed_request["page"]["id"]
			if FacebookPage.find_by_facebook_page_id(@page_id)
				@company = FacebookPage.find_by_facebook_page_id(@page_id).company
			elsif @admin
				redirect_to facebook_setup_path(fb_page_id: @page_id)
				return
			else
				redirect_to iframe_construction_path(admin: @admin, fb_page_id: @page_id)
				return
			end
		elsif params[:company_id]
			@admin = false
			crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
		    id = crypt.decrypt_and_verify(params[:company_id])
		    @company = Company.find(id)
		else
			redirect_to iframe_construction_path
			return
		end

		unless @company.company_setting.activate_workflow && @company.active
			redirect_to iframe_construction_path
			return
		end
		@locations = Location.where(:active => true).where(company_id: @company.id).where(id: ServiceProvider.where(active: true, company_id: @company.id).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: @company.id).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(order: :asc)

		# => Domain parser
		host = request.host_with_port
		@url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

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
