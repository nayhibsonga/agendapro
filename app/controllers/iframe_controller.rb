class IframeController < ApplicationController
	after_action :allow_iframe
	skip_before_action :verify_authenticity_token

	def sampler
		render layout: false
	end

	def construction
		render layout: false
	end

	def facebook_addtab
		render layout: "home"
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
		elsif params[:tabs_added]
			redirect_to facebook_addtab_path
			return
		else
			redirect_to iframe_construction_path
			return
		end

		unless @company && @company.company_setting && @company.active && @company.company_setting.activate_workflow
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
		@bookings = []
    @errors = []
    @blocked_bookings = []

    @location_id = params[:location]
    @selectedLocation = Location.find(@location_id)
    @company = Location.find(params[:location]).company
    cancelled_id = Status.find_by(name: 'Cancelado').id

    # => Domain parser
    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    if @company.company_setting.client_exclusive
      if(params[:client_id])
        client = Client.find(params[:client_id])
      elsif Client.where(identification_number: params[:identification_number], company_id: @company).count > 0
        client = Client.where(identification_number: params[:identification_number], company_id: @company).first
        client.email = params[:email]
        client.phone = params[:phone]
        client.save
        if client.errors
          puts client.errors.full_messages.inspect
        end
      else
        @errors << "No estás ingresado como cliente"
        render layout: "iframe"
        return
      end
    else
      if(params[:client_id])
        client = Client.find(params[:client_id])
      elsif Client.where(email: params[:email], company_id: @company).count > 0
        client = Client.where(email: params[:email], company_id: @company).first
        client.first_name = params[:firstName]
        client.last_name = params[:lastName]
        client.phone = params[:phone]
        client.save
        if client.errors
          puts client.errors.full_messages.inspect
        end
      else
        client = Client.new(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], company_id: @company.id)
        client.save
        if client.errors
          puts client.errors.full_messages.inspect
        end
      end
    end

    if params[:address] && !params[:address].empty?
      params[:comment] += ' - Dirección del cliente (donde se debe realizar el servicio): ' + params[:address]
    end

    booking_data = JSON.parse(params[:bookings], symbolize_names: true)

    deal = nil
    if @company.company_setting.deal_activate
      if Deal.where(code: params[:deal_code], company_id: @company).count > 0
        deal = Deal.where(code: params[:deal_code], company_id: @company).first
        if deal.quantity> 0 && deal.bookings.where.not(status_id: cancelled_id).count >= deal.quantity
          @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida."
        elsif deal.constraint_option > 0 && deal.constraint_quantity > 0
          booking_data.each do |buffer_params|
            if deal.constraint_option == 1
              if deal.bookings.where.not(status_id: cancelled_id).where(start: buffer_params[:start].to_datetime).count >= deal.constraint_quantity
                @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida simultáneamente."
                break
              end
            elsif deal.constraint_option == 2
              if deal.bookings.where.not(status_id: cancelled_id).where(start: buffer_params[:start].to_datetime.beginning_of_day..buffer_params[:start].to_datetime.end_of_day).count >= deal.constraint_quantity
                @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida por día."
                break
              end
            elsif deal.constraint_option == 3
              if deal.bookings.where.not(status_id: cancelled_id).where(start: buffer_params[:start].to_datetime.beginning_of_week..buffer_params[:start].to_datetime.end_of_week).count >= deal.constraint_quantity
                @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida por semana."
                break
              end
            elsif deal.constraint_option == 4
              if deal.bookings.where.not(status_id: cancelled_id).where(start: buffer_params[:start].to_datetime.beginning_of_month..buffer_params[:start].to_datetime.end_of_month).count >= deal.constraint_quantity
                @errors << "Este convenio ya fue utilizado el máximo de veces que era permitida por mes."
                break
              end
            end
          end
        end
        if @errors.length > 0
          render layout: "iframe"
          return
        end
      else
        if !@company.company_setting.deal_exclusive
          deal = Deal.create(company_id: @company.id, code: params[:deal_code], quantity: @company.company_setting.deal_quantity, constraint_option: @company.company_setting.deal_constraint_quantity, constraint_quantity: @company.company_setting.deal_constraint_quantity)
        else
          @errors << "Convenio es inválido o inexistente."
          render layout: "iframe"
          return
        end
      end
    end

    booking_group = nil
    if booking_data.length > 1
      provider = booking_data[0][:provider]
      location = ServiceProvider.find(provider).location

      group = Booking.where(location: location).where.not(booking_group: nil).order(:booking_group).last
      if group.nil?
        booking_group = 0
      else
        booking_group = group.booking_group + 1
      end
    end

    group_payment = false
    if(params[:payment] == "1")
      group_payment = true
    end
    final_price = 0

    booking_data.each do |buffer_params|
      block_it = false
      service_provider = ServiceProvider.find(buffer_params[:provider])
      service = Service.find(buffer_params[:service])
      service_provider.bookings.each do |provider_booking|
        unless provider_booking.status_id == cancelled_id
          if (provider_booking.start.to_datetime - buffer_params[:end].to_datetime) * (buffer_params[:start].to_datetime - provider_booking.end.to_datetime) > 0
            if !service.group_service || buffer_params[:service].to_i != provider_booking.service_id
              @errors << "Lo sentimos, la hora " + I18n.l(buffer_params[:start].to_datetime) + " con " + service_provider.public_name + " ya fue reservada por otro cliente."
              block_it = true
              next
            elsif service.group_service && buffer_params[:service].to_i == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => buffer_params[:start].to_datetime).count >= service.capacity
              @errors << "Lo sentimos, la capacidad del servicio grupal " + service.name + " llegó a su límite."
              block_it = true
              next
            end
          end
        end
      end

      if user_signed_in?
        @booking = Booking.new(
          start: buffer_params[:start],
          end: buffer_params[:end],
          notes: params[:comment],
          service_provider_id: service_provider.id,
          service_id: service.id,
          location_id: @selectedLocation.id,
          status_id: Status.find_by(name: 'Reservado').id,
          client_id: client.id,
          user_id: current_user.id,
          web_origin: params[:origin],
          provider_lock: buffer_params[:provider_lock]
        )
      else
        if User.find_by_email(params[:email])
          @user = User.find_by_email(params[:email])
          @booking = Booking.new(
            start: buffer_params[:start],
            end: buffer_params[:end],
            notes: params[:comment],
            service_provider_id: service_provider.id,
            service_id: service.id,
            location_id: @selectedLocation.id,
            status_id: Status.find_by(name: 'Reservado').id,
            client_id: client.id,
            user_id: @user.id,
            web_origin: params[:origin],
            provider_lock: buffer_params[:provider_lock]
          )
        else
          @booking = Booking.new(
            start: buffer_params[:start],
            end: buffer_params[:end],
            notes: params[:comment],
            service_provider_id: service_provider.id,
            service_id: service.id,
            location_id: @selectedLocation.id,
            status_id: Status.find_by(name: 'Reservado').id,
            client_id: client.id,
            web_origin: params[:origin],
            provider_lock: buffer_params[:provider_lock]
          )
        end
      end



      @booking.price = service.price
      @booking.max_changes = @company.company_setting.max_changes
      @booking.booking_group = booking_group

      if deal
        @booking.deal = deal
      end

      if block_it
        @blocked_bookings << @booking.service.name + " con " + @booking.service_provider.public_name + " el " + I18n.l(@booking.start.to_datetime)
      else
        @bookings << @booking
      end

      #
      #   PAGO EN LÍNEA DE RESERVA
      #
      if(params[:payment] == "1")

        #Check if all payments are payable
        #Apply grouped discount
        if !service.online_payable
          group_payment = false
          # Redirect to error
        end

        #trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
        num_amount = service.price
        if service.has_discount
          num_amount = (service.price - service.price*service.discount/100).round;
        end
        final_price = final_price + num_amount
        @booking.price = num_amount
        #amount = sprintf('%.2f', num_amount)
        #payment_method = params[:mp]
        #req = PuntoPagos::Request.new()
        #resp = req.create(trx_id, amount, payment_method)
        # if resp.success?
        #   @booking.trx_id = trx_id
        #   @booking.token = resp.get_token
        #   if @booking.save
        #     current_user ? user = current_user.id : user = 0
        #     PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: amount, details: "Pago de servicio " + service.name + " a la empresa " +@company.name+" (" + @company.id.to_s + "). trx_id: "+trx_id+" - mp: "+@company.id.to_s+". Resultado: Se procesa")
        #     BookingHistory.create(booking_id: @booking.id, action: "Creada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user)
        #     redirect_to resp.payment_process_url and return
        #   else
        #     @errors = @booking.errors.full_messages
        #   end
        # else
        #   puts resp.get_error
        #   redirect_to punto_pagos_failure_path and return
        # end

      else #SÓLO RESERVA
        if @booking.save
          current_user ? user = current_user.id : user = 0
          BookingHistory.create(booking_id: @booking.id, action: "Creada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user)
        else
          @errors << @booking.errors.full_messages
          @blocked_bookings << @booking.service.name + " con " + @booking.service_provider.public_name + " el " + I18n.l(@booking.start.to_datetime)
        end
      end

    end




    #If they can be payed, redirect to payment_process,
    #then check for error or send notifications mails.
    if group_payment
      trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
      amount = sprintf('%.2f', final_price)
      payment_method = params[:mp]
      req = PuntoPagos::Request.new()
      resp = req.create(trx_id, amount, payment_method)
      if resp.success?
        proceed_with_payment = true
        @bookings.each do |booking|
          booking.trx_id = trx_id
          booking.token = resp.get_token
          if booking.save
            current_user ? user = current_user.id : user = 0
            BookingHistory.create(booking_id: booking.id, action: "Creada por Cliente", start: booking.start, status_id: booking.status_id, service_id: booking.service_id, service_provider_id: booking.service_provider_id, user_id: user)
          else
            @errors << booking.errors.full_messages
            proceed_with_payment = false
          end
        end
        #@blocked_bookings.each do |b_booking|
        #  b_booking.save
        #end

        @bookings.each do |b|
          if b.id.nil?
            @errors << "Hubo un error al guardar un servicio."
            proceed_with_payment = false
          end
        end

        #Check for errors before starting payment
        if @errors.length > 0 and @blocked_bookings.count > 0
          books = []
          @bookings.each do |b|
            if !b.id.nil?
              books << b
            end
          end
          redirect_to iframe_book_error_path(bookings: books.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: "payment", blocked_bookings: @blocked_bookings)
          return
        end

        if proceed_with_payment
          PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: amount, details: "Pago de varios servicios a la empresa " +@company.name+" (" + @company.id.to_s + "). trx_id: "+trx_id+" - mp: "+@company.id.to_s+". Resultado: Se procesa")
          redirect_to resp.payment_process_url and return
        else
          puts resp.get_error
          redirect_to punto_pagos_failure_path and return
        end
      else
        @bookings.each do |booking|
            booking.delete
        end
        puts resp.get_error
        redirect_to punto_pagos_failure_path and return
      end
    end

    str_payment = "book"
    if group_payment
      str_payment = "payment"
    end


    @bookings.each do |b|
      if b.id.nil?
        @errors << "Hubo un error al guardar un servicio."
      end
    end


    if @errors.length > 0 and booking_data.length > 0
      books = []
      @bookings.each do |b|
        if !b.id.nil?
          books << b
        end
      end
      redirect_to iframe_book_error_path(bookings: books.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: str_payment, blocked_bookings: @blocked_bookings)
      return
    end

    if @bookings.length > 1
      Booking.send_multiple_booking_mail(@location_id, booking_group)
    end

    @try_register = false

    if !user_signed_in?
      if !User.find_by_email(params[:email])
        @try_register = true
        @user = User.new
        @user.email = params[:email]
        @user.first_name = params[:firstName]
        @user.last_name = params[:lastName]
        @user.phone = params[:phone]
      end
    end

		render layout: "iframe"
	end

	def book_error

    @client = Client.find(params[:client])

    @try_register = false

    if !user_signed_in?
      if !User.find_by_email(@client.email)
        @try_register = true
        @user = User.new
        @user.email = @client.email
        @user.first_name = @client.first_name
        @user.last_name = @client.last_name
        @user.phone = @client.phone
      end
    end


    @location = Location.find(params[:location])
    @company = @location.company
    
    @tried_bookings = []
    if(params[:bookings])
      @tried_bookings = Booking.find(params[:bookings])
    end
    @payment = params[:payment]
    @blocked_bookings = params[:blocked_bookings]
    @errors = params[:errors]
    @bookings = []

    #If payed, delete them all.
    if @payment == "payment"
      @tried_bookings.each do |booking|
        booking.delete
      end
    else #Create fake bookings and delete the real ones
      @tried_bookings.each do |booking|
        fake_booking = Booking.new(booking.attributes.to_options)
        @bookings << fake_booking
        booking.delete
      end
    end

    host = request.host_with_port
    @url = @company.web_address + '.' + host[host.index(request.domain)..host.length]

    render layout: "iframe"
  end

	private

	def allow_iframe
		response.headers.except! 'X-Frame-Options'
	end
end
