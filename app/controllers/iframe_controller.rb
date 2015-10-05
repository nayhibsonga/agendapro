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
			app_secret = ENV["FACEBOOK_APP_SECRET"]
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

    booking_data = JSON.parse(params[:bookings], symbolize_names: true)

    if !user_signed_in?
      if params[:mailing_option].blank?
        params[:mailing_option] = false
      end
      if MailingList.where(email: params[:email]).count > 0
        MailingList.where(email: params[:email]).first.update(first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], mailing_option: params[:mailing_option])
      else
        MailingList.create(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], mailing_option: params[:mailing_option])
      end
    end

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
        render layout: "workflow"
        return
      end
    else
      if Client.where(email: params[:email], company_id: @company).count > 0
        client = Client.where(email: params[:email], company_id: @company).first
        client.first_name = params[:firstName]
        client.last_name = params[:lastName]
        client.phone = params[:phone]
        if client.save

        else
          @errors << client.errors.full_messages
          logger.debug "Client errors 1"
          logger.debug @errors.inspect
        end
      else
        client = Client.new(email: params[:email], first_name: params[:firstName], last_name: params[:lastName], phone: params[:phone], company_id: @company.id)
        if client.save

        else
          @errors << client.errors.full_messages
          logger.debug "Client errors 2"
          logger.debug @errors.inspect
        end
      end
    end

    if params[:comment].blank?
      params[:comment] = ''
    end

    if params[:address] && !params[:address].empty?
      params[:comment] += ' - Dirección del cliente (donde se debe realizar el servicio): ' + params[:address]
    end

    #booking_data = JSON.parse(params[:bookings], symbolize_names: true)
    #is_session_booking = booking_data[0].has_sessions

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
          render layout: "workflow"
          return
        end
      else
        if !@company.company_setting.deal_exclusive
          deal = Deal.create(company_id: @company.id, code: params[:deal_code], quantity: @company.company_setting.deal_quantity, constraint_option: @company.company_setting.deal_constraint_quantity, constraint_quantity: @company.company_setting.deal_constraint_quantity)
        else
          @errors << "Convenio es inválido o inexistente."
          render layout: "workflow"
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

    @session_booking = nil
    @has_session_booking = false
    first_booking = nil
    sessions_service = nil

    if booking_data.size > 0
      if(params[:has_sessions] == "1" || params[:has_sessions] == 1)
        @has_session_booking = true
        @session_booking = SessionBooking.new
        session_service = Service.find(booking_data.first[:service])
        @session_booking.service_id = session_service.id
        @session_booking.client_id = client.id
        @session_booking.sessions_amount = session_service.sessions_amount
        @session_booking.max_discount = params[:max_discount].to_f
        if user_signed_in?
          @session_booking.user_id = current_user.id
        end
        #@session_booking.sessions_taken = booking_data.size
        @session_booking.save
      end
    end

    #Get service_promos and lower their stock
    service_promos_ids = []

    booking_data.each do |buffer_params|
      block_it = false
      service_provider = ServiceProvider.find(buffer_params[:provider])
      service = Service.find(buffer_params[:service])
      service_provider.provider_breaks.where("provider_breaks.start < ?", buffer_params[:end].to_datetime).where("provider_breaks.end > ?", buffer_params[:start].to_datetime).each do |provider_break|
        if (provider_break.start.to_datetime - buffer_params[:end].to_datetime) * (buffer_params[:start].to_datetime - provider_break.end.to_datetime) > 0
          if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
            @errors << "Lo sentimos, la hora " + I18n.l(buffer_params[:start].to_datetime) + " con " + service_provider.public_name + " está bloqueada."
            block_it = true
            next
          end
        end
      end
      service_provider.bookings.where("bookings.start < ?", buffer_params[:end].to_datetime).where("bookings.end > ?", buffer_params[:start].to_datetime).where('bookings.is_session = false or (bookings.is_session = true and bookings.is_session_booked = true)').each do |provider_booking|
        unless provider_booking.status_id == cancelled_id
          if (provider_booking.start.to_datetime - buffer_params[:end].to_datetime) * (buffer_params[:start].to_datetime - provider_booking.end.to_datetime) > 0
            if !service.group_service || buffer_params[:service].to_i != provider_booking.service_id
              if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
                @errors << "Lo sentimos, la hora " + I18n.l(buffer_params[:start].to_datetime) + " con " + service_provider.public_name + " ya fue reservada por otro cliente."
                block_it = true
                next
              end
            elsif service.group_service && buffer_params[:service].to_i == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => buffer_params[:start].to_datetime).where.not(status_id: Status.find_by_name('Cancelado')).count >= service.capacity
              if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
                @errors << "Lo sentimos, la capacidad del servicio grupal " + service.name + " llegó a su límite."
                block_it = true
                next
              end
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
        if service.online_payable && buffer_params[:is_time_discount]
          service_promos_ids << buffer_params[:service_promo_id]
        end
        @bookings << @booking
      end

      if @has_session_booking
        @booking.is_session = true
        @booking.session_booking_id = @session_booking.id
        @booking.user_session_confirmed = true
        @booking.is_session_booked = true
      end

      #
      #   PAGO EN LÍNEA DE RESERVA
      #
      if(params[:payment] == "1")

        group_payment = true
        #Check if all payments are payable
        #Apply grouped discount

        #Check if all are payable
        #If not, pay those which may be paid
        #and book the others

        #if !service.online_payable
          #group_payment = false
          # Redirect to error
        #end

        #trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
        if service.online_payable

          if(params[:has_sessions] == "1" || params[:has_sessions] == 1)

            max_discount = params[:max_discount].to_f
            num_amount = (service.price - max_discount*service.price/100).round
            @booking.price = num_amount
            final_price = num_amount

            if buffer_params[:is_time_discount]
              @session_booking.service_promo_id = buffer_params[:service_promo_id]
              @booking.service_promo_id = buffer_params[:service_promo_id]
            end
          else

            #num_amount = service.price
            #if service.has_discount
            #  num_amount = (service.price - service.price*service.discount/100).round;
            #end
              #final_price = final_price + num_amount
            #if @has_session_booking
              #final_price = num_amount
            #end

            num_amount = (service.price - buffer_params[:discount]*service.price/100).round

            if buffer_params[:is_time_discount]
              @booking.service_promo_id = buffer_params[:service_promo_id]
              service_promo = ServicePromo.find(buffer_params[:service_promo_id])
              #service_promo.max_bookings = service_promo.max_bookings - 1
            end

            @booking.price = num_amount
            final_price = final_price + num_amount

          end
        else
          @booking.price = service.price
        end
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
          BookingHistory.create(booking_id: @booking.id, action: "Creada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)
          logger.debug "Creada 1"
          if first_booking.nil?
            first_booking = @booking
          end
        else
          @errors << @booking.errors.full_messages
          @blocked_bookings << @booking.service.name + " con " + @booking.service_provider.public_name + " el " + I18n.l(@booking.start.to_datetime)
        end
      end

    end

    #If they can be payed, redirect to payment_process,
    #then check for error or send notifications mails.
    if group_payment

      trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')[0, 15]

      #######
      # START Recalculate final price so that there is no js injection
      #######

      if @has_session_booking

        sessions_max_discount = 0
        if @bookings.count > 0

          current_service = @bookings.first.service
          if !current_service.online_payable || !current_service.company.company_setting.online_payment_capable || !current_service.company.company_setting.allows_online_payment

            @errors << "El servicio " + current_service.name + " no puede ser pagado en línea."

            redirect_to book_error_path(bookings: @bookings.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: "payment", blocked_bookings: @blocked_bookings)
            return

          else

            # If discount is for online_payment, it's always equal.
            if current_service.has_discount && current_service.discount > 0
              @bookings.each do |booking|
                new_price = (service.price - current_service.discount*service.price/100).round
                booking.price = new_price
                final_price = new_price
              end
            elsif current_service.has_time_discount

              #Look for the highest discount
              @bookings.each do |booking|

                promo = Promo.where(:day_id => booking.start.to_datetime.cwday, :service_promo_id => @session_booking.service_promo_id, :location_id => @selectedLocation.id).first

                if !promo.nil?

                  service_promo = ServicePromo.find(current_service.active_service_promo_id)

                  #Check if there is a limit for bookings, and if there are any left
                  if service_promo.max_bookings > 0 || !service_promo.limit_booking

                    #Check if the promo is still active, and if the booking ends before the limit date

                    if booking.end.to_datetime < service_promo.book_limit_date && DateTime.now < service_promo.finish_date

                      if !(service_promo.morning_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.morning_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))

                        if sessions_max_discount == 0
                          sessions_max_discount = promo.morning_discount
                        else
                          if sessions_max_discount > promo.morning_discount
                            sessions_max_discount = promo.morning_discount
                          end
                        end

                      elsif !(service_promo.afternoon_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.afternoon_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))

                        if sessions_max_discount == 0
                          sessions_max_discount = promo.afternoon_discount
                        else
                          if sessions_max_discount > promo.afternoon_discount
                            sessions_max_discount = promo.afternoon_discount
                          end
                        end

                      elsif !(service_promo.night_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.night_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))

                        if sessions_max_discount == 0
                          sessions_max_discount = promo.night_discount
                        else
                          if sessions_max_discount > promo.night_discount
                            sessions_max_discount = promo.night_discount
                          end
                        end
                      end

                    end

                  end

                end

              end

              @session_booking.max_discount = sessions_max_discount
              # End of get discount
              @bookings.each do |booking|
                new_price = (booking.service.price - sessions_max_discount*booking.service.price/100).round
                booking.price = new_price
                final_price = new_price
              end

            end

          end

        end
      else

        #Reset final_price

        final_price = 0

        # Just check for discount, correct the price and calculate final_price
        @bookings.each do |booking|

          if !booking.service.online_payable || !booking.service.company.company_setting.online_payment_capable || !booking.service.company.company_setting.allows_online_payment

            booking.price = booking.service.price

          else

            if booking.service.has_discount && booking.service.discount > 0

              new_book_price = (booking.service.price - booking.service.discount*booking.service.price/100).round
              booking.price = new_book_price
              final_price = final_price + new_book_price

            else

              promo = Promo.where(:day_id => booking.start.to_datetime.cwday, :service_promo_id => booking.service.active_service_promo_id, :location_id => @selectedLocation.id).first

              new_book_discount = 0

              if !promo.nil?

                service_promo = ServicePromo.find(booking.service.active_service_promo_id)

                #Check if there is a limit for bookings, and if there are any left
                if service_promo.max_bookings > 0 || !service_promo.limit_booking

                  #Check if the promo is still active, and if the booking ends before the limit date

                  if booking.end.to_datetime < service_promo.book_limit_date && DateTime.now < service_promo.finish_date

                    if !(service_promo.morning_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.morning_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))
                      
                      new_book_discount = promo.morning_discount

                    elsif !(service_promo.afternoon_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.afternoon_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))

                      new_book_discount = promo.afternoon_discount

                    elsif !(service_promo.night_start.strftime("%H:%M") >= booking.end.strftime("%H:%M") || service_promo.night_end.strftime("%H:%M") <= booking.start.strftime("%H:%M"))

                      new_book_discount = promo.night_discount

                    end

                  end

                end

              end

              new_book_price = (booking.service.price - new_book_discount*booking.service.price/100).round
              booking.price = new_book_price
              final_price = final_price + new_book_price

            end

          end

        end
      end

      #####
      # END Recalculate final price so that there is no js injection
      #####


      amount = sprintf('%.2f', final_price)
      payment_method = params[:mp]
      req = PuntoPagos::Request.new()
      resp = req.create(trx_id, amount, payment_method)
      if resp.success?
        proceed_with_payment = true
        @bookings.each do |booking|

          if booking.service.online_payable
            booking.trx_id = trx_id
            booking.token = resp.get_token

            if booking.save
              current_user ? user = current_user.id : user = 0
              BookingHistory.create(booking_id: booking.id, action: "Creada por Cliente", start: booking.start, status_id: booking.status_id, service_id: booking.service_id, service_provider_id: booking.service_provider_id, user_id: user, notes: booking.notes, company_comment: booking.company_comment)
              logger.debug "Creada 2"
              if first_booking.nil?
                first_booking = booking
              end

            else
              @errors << booking.errors.full_messages
              proceed_with_payment = false
            end
          else
            if booking.save
              current_user ? user = current_user.id : user = 0
              BookingHistory.create(booking_id: booking.id, action: "Creada por Cliente", start: booking.start, status_id: booking.status_id, service_id: booking.service_id, service_provider_id: booking.service_provider_id, user_id: user, notes: booking.notes, company_comment: booking.company_comment)
              logger.debug "Creada 3"
              if first_booking.nil?
                first_booking = booking
              end
            else
              @errors << booking.errors.full_messages
              proceed_with_payment = false
            end
          end
        end
        #@blocked_bookings.each do |b_booking|
        #  b_booking.save
        #end

        @bookings.each do |b|
          if b.id.nil?
            @errors << "Hubo un error al guardar un servicio." + b.errors.inspect
            @blocked_bookings << b.service.name + " con " + b.service_provider.public_name + " el " + I18n.l(b.start.to_datetime)
            proceed_with_payment = false
          end
        end


        if @has_session_booking

          #@session_booking.sessions_taken = @bookings.size
          sessions_missing = @session_booking.sessions_amount - @bookings.size
          @session_booking.sessions_taken = @bookings.size
          @session_booking.save


          for i in 0..sessions_missing-1

            if !first_booking.nil?
              new_booking = first_booking.dup
              new_booking.is_session = true
              new_booking.session_booking_id = @session_booking.id
              new_booking.user_session_confirmed = false
              new_booking.is_session_booked = false

              if new_booking.save
                @bookings << new_booking
                current_user ? user = current_user.id : user = 0
                BookingHistory.create(booking_id: new_booking.id, action: "Creada por Cliente", start: new_booking.start, status_id: new_booking.status_id, service_id: new_booking.service_id, service_provider_id: new_booking.service_provider_id, user_id: user, notes: new_booking.notes, company_comment: new_booking.company_comment)
                logger.debug "Creada 4"
              else
                @errors << new_booking.errors.full_messages
                @blocked_bookings << new_booking.service.name + " con " + new_booking.service_provider.public_name + " el " + I18n.l(new_booking.start.to_datetime)
                proceed_with_payment = false
              end
            else
              @errors << "No existen sesiones agendadas."
              @blocked_bookings << "No existen sesiones agendadas."
              proceed_with_payment = false
            end
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
          redirect_to book_error_path(bookings: books.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: "payment", blocked_bookings: @blocked_bookings)
          return
        end

        if proceed_with_payment

          if @has_session_booking
            service_promo = ServicePromo.find(@bookings.first.service.active_service_promo_id)
            service_promo.max_bookings = service_promo.max_bookings - 1
            service_promo.save
          else
            @bookings.each do |booking|
              if !booking.service_promo_id.nil?
                service_promo = ServicePromo.find(booking.service_promo_id)
                service_promo.max_bookings = service_promo.max_bookings - 1
                service_promo.save
              end
            end
          end     

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

    #Add bookings for all the sessions that where not booked
    if @has_session_booking

      #@session_booking.sessions_taken = @bookings.size
      sessions_missing = @session_booking.sessions_amount - @bookings.size
      @session_booking.sessions_taken = @bookings.size
      @session_booking.save


      for i in 0..sessions_missing-1

        if !first_booking.nil?
          new_booking = first_booking.dup
          new_booking.is_session = true
          new_booking.session_booking_id = @session_booking.id
          new_booking.user_session_confirmed = false
          new_booking.is_session_booked = false

          if new_booking.save
            @bookings << new_booking
            current_user ? user = current_user.id : user = 0
            BookingHistory.create(booking_id: new_booking.id, action: "Creada por Cliente", start: new_booking.start, status_id: new_booking.status_id, service_id: new_booking.service_id, service_provider_id: new_booking.service_provider_id, user_id: user, notes: new_booking.notes, company_comment: new_booking.company_comment)
            logger.debug "Creada 5"
          else
            @errors << new_booking.errors.full_messages
            @blocked_bookings << new_booking.service.name + " con " + new_booking.service_provider.public_name + " el " + I18n.l(new_booking.start.to_datetime)
          end
        else
          @errors << "No existen sesiones agendadas."
          @blocked_bookings << "No existen sesiones agendadas."
        end
      end

    end

    str_payment = "book"
    if group_payment
      str_payment = "payment"
    end

    @bookings.each do |b|
      if b.id.nil?
        @errors << "Hubo un error al guardar un servicio. " + b.errors.inspect
        @blocked_bookings << b.service.name + " con " + b.service_provider.public_name + " el " + I18n.l(b.start.to_datetime)
      end
    end

    logger.debug "Llega a errors"
    logger.debug @errors.inspect

    if @errors.length > 0 and booking_data.length > 0
      if @errors.first.length > 0
        books = []
        @bookings.each do |b|
          if !b.id.nil?
            books << b
          end
        end
        redirect_to book_error_path(bookings: books.map{|b| b.id}, location: @selectedLocation.id, client: client.id, errors: @errors, payment: str_payment, blocked_bookings: @blocked_bookings)
        return
      end
    end

    if @bookings.length > 1
      if @session_booking.nil?
        Booking.send_multiple_booking_mail(@location_id, booking_group)
      else
        @session_booking.send_sessions_booking_mail
      end
    end

    logger.debug "Llega al final"

    @try_register = false
    @try_signin = false

    if !user_signed_in?
      if !User.find_by_email(params[:email])
        @try_register = true
        @user = User.new
        @user.email = params[:email]
        @user.first_name = params[:firstName]
        @user.last_name = params[:lastName]
        @user.phone = params[:phone]
      else
        @try_signin = true
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

    render layout: "iframe"
  end

	private

	def allow_iframe
		response.headers.delete "X-Frame-Options"
	end
end
