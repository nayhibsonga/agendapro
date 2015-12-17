module ApiViews
  module Marketplace
	module V1
	  class BookingsController < V1Controller
	  	skip_before_filter :permitted_params, only: [:book_service, :edit_booking]

	  	include ApplicationHelper

	  	def book_service
		    if params[:location_id].blank?
		      render json: { errors: "El local ingresado no existe." }, status: 422
			  return
		    elsif params[:bookings].blank?
		      render json: { errors: "Error ingresando los datos." }, status: 422
			  return
		    end

		    @bookings = []
		    @errors = []
		    @blocked_bookings = []

		    @location_id = params[:location_id]
		    @selectedLocation = Location.find(@location_id)
		    @company = @selectedLocation.company
		    cancelled_id = Status.find_by(name: 'Cancelado').id

		    full_name = split_name(client_params[:name])
		    client_params.merge!(full_name)

		    puts full_name.inspect

		    booking_data = booking_params[:bookings]
		    puts booking_data.inspect

		    if @api_user.id
		      if client_params[:mailing_option].blank?
		        client_params[:mailing_option] = false
		      end
		      if MailingList.where(email: client_params[:email]).count > 0
		        MailingList.where(email: client_params[:email]).first.update(first_name: full_name[:first_name], last_name: full_name[:last_name], phone: client_params[:phone], mailing_option: client_params[:mailing_option])
		      else
		        MailingList.create(email: client_params[:email], first_name: full_name[:first_name], last_name: full_name[:last_name], phone: client_params[:phone], mailing_option: client_params[:mailing_option])
		      end
		    end

		    if @company.company_setting.client_exclusive
		      if(client_params[:client_id])
		        client = Client.find(client_params[:client_id])
		      elsif Client.where(identification_number: client_params[:identification_number], company_id: @company).count > 0
		        client = Client.where(identification_number: client_params[:identification_number], company_id: @company).first
		        client.email = client_params[:email]
		        client.phone = client_params[:phone]
		        if client.save

		        else
		          @errors << client.errors.full_messages
		          render json: { errors: "No estás ingresado como cliente." }, status: 422
			      return
		        end
		      else
		        render json: { errors: "No estás ingresado como cliente." }, status: 422
			    return
		      end
		    else
		      if Client.where(email: client_params[:email], company_id: @company).count > 0
		        client = Client.where(email: client_params[:email], company_id: @company).first
		        client.first_name = full_name[:first_name]
		        client.last_name = full_name[:last_name]
		        client.phone = client_params[:phone]
		        client.save
		      else
		        client = Client.new(email: client_params[:email], first_name: full_name[:first_name], last_name: full_name[:last_name], phone: client_params[:phone], company_id: @company.id)
		        if client.save

		        else
		          @errors << client.errors.full_messages
		          render json: { errors: @errors.inspect }, status: 422
			    return
		        end
		      end
		    end

		    if client_params[:notes].blank?
		      client_params[:notes] = ''
		    end

		    if client_params[:address] && !client_params[:address].empty?
		      client_params[:notes] += ' - Dirección del cliente (donde se debe realizar el servicio): ' + client_params[:address]
		    end

		    #booking_data = JSON.parse(params[:bookings], symbolize_names: true)
		    #is_session_booking = booking_data[0].has_sessions

		    deal = nil
		    if @company.company_setting.deal_activate
		      if Deal.where(code: client_params[:deal_code], company_id: @company).count > 0
		        deal = Deal.where(code: client_params[:deal_code], company_id: @company).first
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
		          render json: { errors: @errors.inspect }, status: 422
			  	  return
		        end
		      else
		        if !@company.company_setting.deal_exclusive
		          deal = Deal.create(company_id: @company.id, code: client_params[:deal_code], quantity: @company.company_setting.deal_quantity, constraint_option: @company.company_setting.deal_constraint_quantity, constraint_quantity: @company.company_setting.deal_constraint_quantity)
		        else
		          @errors << "Convenio es inválido o inexistente."
		          render json: { errors: @errors.inspect }, status: 422
			  	  return
		        end
		      end
		    end



		    booking_group = nil
		    if booking_data.length > 1
		    	puts booking_data[0].inspect
		      provider = booking_data[0][:provider_id]
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
		      service_provider = ServiceProvider.find(buffer_params[:provider_id])
		      service = Service.find(buffer_params[:service_id])
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
		            if !service.group_service || service.id != provider_booking.service_id
		              if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
		                @errors << "Lo sentimos, la hora " + I18n.l(buffer_params[:start].to_datetime) + " con " + service_provider.public_name + " ya fue reservada por otro cliente."
		                block_it = true
		                next
		              end
		            elsif service.group_service && service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => buffer_params[:start].to_datetime).where.not(status_id: Status.find_by_name('Cancelado')).count >= service.capacity
		              if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
		                @errors << "Lo sentimos, la capacidad del servicio grupal " + service.name + " llegó a su límite."
		                block_it = true
		                next
		              end
		            end
		          end
		        end
		      end

		      if @api_user.id
		        @booking = Booking.new(
		          start: buffer_params[:start],
		          end: buffer_params[:end],
		          notes: client_params[:notes],
		          service_provider_id: service_provider.id,
		          service_id: service.id,
		          location_id: @selectedLocation.id,
		          status_id: Status.find_by(name: 'Reservado').id,
		          client_id: client.id,
		          user_id: @api_user.id,
		          web_origin: true,
		          marketplace_origin: true,
		          provider_lock: buffer_params[:provider_lock]
		      )
		      else
		        if User.find_by_email(params[:email])
		          @user = User.find_by_email(params[:email])
		          @booking = Booking.new(
		            start: buffer_params[:start],
		            end: buffer_params[:end],
		            notes: client_params[:notes],
		            service_provider_id: service_provider.id,
		            service_id: service.id,
		            location_id: @selectedLocation.id,
		            status_id: Status.find_by(name: 'Reservado').id,
		            client_id: client.id,
		            user_id: @user.id,
		            web_origin: true,
		          	marketplace_origin: true,
		            provider_lock: buffer_params[:provider_lock]
		        )
		        else
		          @booking = Booking.new(
		            start: buffer_params[:start],
		            end: buffer_params[:end],
		            notes: client_params[:notes],
		            service_provider_id: service_provider.id,
		            service_id: service.id,
		            location_id: @selectedLocation.id,
		            status_id: Status.find_by(name: 'Reservado').id,
		            client_id: client.id,
		            web_origin: true,
		          	marketplace_origin: true,
		            provider_lock: buffer_params[:provider_lock]
		        )
		        end
		      end


		      @booking.price = service.price
		      @booking.list_price = service.price
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

		            @booking.service_promo_id = nil
		            @booking.last_minute_promo_id = nil

		            if buffer_params[:is_treatment_discount]
		              @session_booking.treatment_promo_id = buffer_params[:treatment_promo_id]
		              @booking.treatment_promo_id = buffer_params[:treatment_promo_id]
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

		            num_amount = (service.price - buffer_params[:discount].to_f * service.price / 100).round

		            if buffer_params[:is_time_discount]
		              @booking.service_promo_id = buffer_params[:service_promo_id]
		              service_promo = ServicePromo.find(buffer_params[:service_promo_id])
		              #service_promo.max_bookings = service_promo.max_bookings - 1
		            elsif buffer_params[:is_last_minute_promo]
		              @booking.last_minute_promo_id = @booking.service.active_last_minute_promo_id
		              last_minute_promo = @booking.service.active_last_minute_promo
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

		            render json: { errors: @errors.inspect }, status: 422
			  	    	return

		          else

		          	treatment_discount = 0

		          	#
								# Assign prices in case there is no discount
								#
								@bookings.each do |booking|
								 booking.price = current_service.price / current_service.sessions_amount
								 booking.list_price = current_service.price / current_service.sessions_amount
								 booking.discount = 0
								end

		            # If discount is for online_payment, it's always equal.
		            if current_service.has_discount && current_service.discount > 0
		              @bookings.each do |booking|
		                new_price = booking.price.to_f*((100.0 - current_service.discount.to_f)/100.0)
		                booking.price = new_price
		                final_price = new_price
		                if(booking.list_price > 0)
		                  booking.discount = current_service.discount.to_f
                  		treatment_discount = booking.discount
		                else
		                  booking.discount = 0
		                end
		              end
		            end
		            #Check for promotions
								if current_service.time_promo_active && current_service.has_treatment_promo && !current_service.active_treatment_promo.nil?
								  if current_service.active_treatment_promo.max_bookings > 0 && current_service.active_treatment_promo.finish_date.end_of_day > DateTime.now

								    @bookings.each do |booking|
								      if current_service.active_treatment_promo.discount > booking.discount
								        new_price = booking.price.to_f*((100.0 - booking.service.active_treatment_promo.discount.to_f/100.0))
								        booking.price = new_price
								        #final_price = new_price
								        if(booking.list_price > 0)
								          booking.discount = booking.service.active_treatment_promo.discount.to_f
								          treatment_discount = booking.discount
								        else
								          booking.discount = 0
								        end
								      end
								    end

								  end
								end
		          end
		          #Sum all booking prices (it could have service discount or treatment_promo)

          		final_price = current_service.price * ((100.0 - treatment_discount.to_f)/100.0)

		        end
		      else

		        #Reset final_price

		        final_price = 0

		        # Just check for discount, correct the price and calculate final_price
		        @bookings.each do |booking|

		          if !booking.service.online_payable || !booking.service.company.company_setting.online_payment_capable || !booking.service.company.company_setting.allows_online_payment

		            booking.price = booking.service.price
		            logger.debug "list_price: " + booking.list_price.to_s
		            logger.debug "price: " + booking.price.to_s

		            if(booking.list_price > 0)
		              booking.discount = (100*(booking.list_price - booking.price)/booking.list_price).round
		            else
		              booking.discount = 0
		            end

		          else

		          	#Assume there is no discount at first
								booking.price = booking.service.price
								booking.list_price = booking.service.price
								booking.discount = 0

								#First, check if it is last_minute_promo
								if params[:is_last_minute_promo]

									last_minute_promo = booking.service.active_last_minute_promo

									#LastMinutePromo.where(location_id: @selectedLocation.id, service_id: booking.service.id).first

									if last_minute_promo.nil? 

									 @errors << "La promoción de último minuto ya no existe."

									 render json: { errors: @errors.inspect }, status: 422
									 return

									end

									if LastMinutePromoLocation.where(last_minute_promo_id: last_minute_promo.id, location_id: @selectedLocation.id).count == 0

									  @errors << "La promoción de último minuto no existe para este local."

									  render json: { errors: @errors.inspect }, status: 422
										return

									end

									new_price = (booking.service.price - last_minute_promo.discount*booking.service.price/100).round
									booking.price = new_price
									#final_price = new_price
									if(booking.list_price > 0)
									 booking.discount = (100*(booking.list_price - booking.price)/booking.list_price).round
									else
									 booking.discount = 0
									end
								else
		              #Check for online payment discount
		              if booking.service.has_discount && booking.service.discount > 0

		                new_book_price = (booking.service.price - booking.service.discount*booking.service.price/100).round
		                booking.price = new_book_price
		                booking.discount = booking.service.discount
		                #final_price = final_price + new_book_price

		              end

		              #Now check for promos
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

		              if booking.discount.nil? || booking.discount == 0 || booking.discount < new_book_discount

		                new_book_price = (booking.service.price - new_book_discount*booking.service.price/100).round
		                booking.price = new_book_price
		                #final_price = final_price + new_book_price
		                if(booking.list_price > 0)
		                  booking.discount = (100*(booking.list_price - booking.price)/booking.list_price).round
		                else
		                  booking.discount = 0
		                end
		              end        

		            end

		          end

		        end
		        #Prices were set, now sum them
						if @bookings.count > 0
							@bookings.each do |booking|
						  	final_price += booking.price
							end
						end
		      end

		      #####
		      # END Recalculate final price so that there is no js injection
		      #####


		      amount = sprintf('%.2f', final_price)
		      payment_method = params[:mp]
		      req = PuntoPagos::Request.new()
		      resp = req.create(trx_id, amount, '03')
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
		          render json: { errors: @errors.inspect }, status: 422
			  	  	return
		        end

		        if proceed_with_payment
		          if @has_session_booking
								if !@bookings.first.service.active_treatment_promo_id.nil?
									treatment_promo = TreatmentPromo.find(@bookings.first.service.active_treatment_promo_id)
									treatment_promo.max_bookings = treatment_promo.max_bookings - 1
									treatment_promo.save
								end
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
			          render json: {redirect_to: resp.payment_process_url}
			        return
		        else
		          puts resp.get_error
		          render json: {redirect_to: punto_pagos_failure_path}
		          return
		        end
		      else
		        @bookings.each do |booking|
		            booking.delete
		        end
		        puts resp.get_error
		        render json: {redirect_to: punto_pagos_failure_path}
		        return
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
		        render json: { errors: @errors.inspect }, status: 422
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
		    if @bookings.count < 1
		    	render json: { errors: 'No se agendaron servicios.' }, status: 422
				return
		    else
			    render json: { redirect_to: @bookings.first.marketplace_url }, status: 200
				return
			end

		end

		def edit_booking

		    @bookings = []
		    @blocked_bookings = []

		    @booking = Booking.find(params[:id])
		    @service_provider = ServiceProvider.find(editing_params[:service_provider_id])
		    @selectedLocation = @booking.location
		    @service = @booking.service
		    @company = @selectedLocation.company
		    cancelled_id = Status.find_by(name: 'Cancelado').id

			now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
			booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0

			if (booking_start <=> now) < 1
				render json: { errors: "La empresa permite edición de las reservas sólo " + @company.company_setting.before_edit_booking.to_s + " horas antes de la misma." }, status: 422
			    return
			end

		    #Revisar si fue pagada en línea.
		    #Si lo fue, revisar política de modificación.
		    if @booking.payed || !@booking.payed_booking.nil?
		      if !@booking.is_session
		        if !@company.company_setting.online_cancelation_policy.nil?
		          ocp = @company.company_setting.online_cancelation_policy
		          if !ocp.modifiable
		            render json: { errors: "La empresa permite modificación de las reservas pagadas en línea." }, status: 422
			        return
		          else
		            #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea

		            #Mínimo
		            book_start = DateTime.parse(@booking.start.to_s)
		            min_hours = (book_start-now)/(60*60)
		            min_hours = min_hours.to_i.abs

		            if min_hours >= ocp.min_hours.to_i
		              render json: { errors: "La empresa permite modificación de las reservas sólo hasta #{ocp.min_hours} #{ocp.min_hours} después." }, status: 422
			          return
		            end

		            #Máximo
		            booking_creation = DateTime.parse(@booking.created_at.to_s)
		            minutes = (booking_creation.to_time - now.to_time)/(60)
		            hours = (booking_creation.to_time - now.to_time)/(60*60)
		            days = (booking_creation.to_time - now.to_time)/(60*60*24)
		            minutes = minutes.to_i.abs
		            hours = hours.to_i.abs
		            days = days.to_i.abs
		            weeks = days/7
		            months = days/30

		            #Obtener el máximo
		            num = ocp.modification_max.to_i
		            if ocp.modification_unit == TimeUnit.find_by_unit("Minutos").id
		              if minutes >= num
		                render json: { errors: "La empresa permite modificación de las reservas sólo hasta #{ocp.modification_max} #{ocp.modification_unit} antes." }, status: 422
			            return
		              end
		            elsif ocp.modification_unit == TimeUnit.find_by_unit("Horas").id
		              if hours >= num
		                render json: { errors: "La empresa permite modificación de las reservas sólo hasta #{ocp.modification_max} #{ocp.modification_unit} antes." }, status: 422
			            return
		              end
		            elsif ocp.modification_unit == TimeUnit.find_by_unit("Semanas").id
		              if weeks >= num
		                render json: { errors: "La empresa permite modificación de las reservas sólo hasta #{ocp.modification_max} #{ocp.modification_unit} antes." }, status: 422
			            return
		              end
		            elsif ocp.modification_unit == TimeUnit.find_by_unit("Meses").id
		              if months >= num
		                render json: { errors: "La empresa permite modificación de las reservas sólo hasta #{ocp.modification_max} #{ocp.modification_unit} antes." }, status: 422
			            return
		              end
		            end

		          end
		        end
		      end
		    end

			service_provider = ServiceProvider.find(editing_params[:service_provider_id])
			service = @service
			service_provider.provider_breaks.where("provider_breaks.start < ?", editing_params[:end].to_datetime).where("provider_breaks.end > ?", editing_params[:start].to_datetime).each do |provider_break|
			if (provider_break.start.to_datetime - editing_params[:end].to_datetime) * (editing_params[:start].to_datetime - provider_break.end.to_datetime) > 0
			    render json: { errors: "El horario que estás tratando de reservas está bloqueado." }, status: 422
			    return
			end
			end
			service_provider.bookings.where("bookings.start < ?", editing_params[:end].to_datetime).where("bookings.end > ?", editing_params[:start].to_datetime).where('bookings.is_session = false or (bookings.is_session = true and bookings.is_session_booked = true)').each do |provider_booking|
			unless provider_booking.status_id == cancelled_id
			  if (provider_booking.start.to_datetime - editing_params[:end].to_datetime) * (editing_params[:start].to_datetime - provider_booking.end.to_datetime) > 0
			    if !service.group_service || service.id != provider_booking.service_id
			      if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
			        render json: { errors: "La hora que estás tratando de tomar no está disponible." }, status: 422
			        return
			      end
			    elsif service.group_service && service.id == provider_booking.service_id && service_provider.bookings.where(:service_id => service.id, :start => editing_params[:start].to_datetime).where.not(status_id: cancelled_id).count >= service.capacity
			      if !provider_booking.is_session || (provider_booking.is_session and provider_booking.is_session_booked)
			        render json: { errors: "El servicio grupal ya ha llegado a su capacidad máxima." }, status: 422
			        return
			      end
			    end
			  end
			end
			end

			@booking.max_changes -= 1

			if @booking.is_session
				@booking.is_session_booked = true
				@booking.user_session_confirmed = true
			end


		    if @booking.update(editing_params)
	          @api_user ? user = @api_user.id : user = 0
	          BookingHistory.create(booking_id: @booking.id, action: "Editada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)
	        else
	        	render json: { errors: @booking.errors.full_messages.inspect }, status: 422
		        return
	        end
		end

		def destroy
		  	@booking = Booking.find(params[:id])


			@company = Location.find(@booking.location_id).company
			@selectedLocation = Location.find(@booking.location_id)

			now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
			booking_start = DateTime.parse(@booking.start.to_s) - @company.company_setting.before_edit_booking / 24.0

			if (booking_start <=> now) < 1
				render json: { errors: "La empresa permite anulación de las reservas sólo " + @company.company_setting.before_edit_booking.to_s + " horas antes de la misma." }, status: 422
			    return
			end

			#Revisar si fue pagada en línea.
			#Si lo fue, revisar política de modificación.
			if @booking.payed || !@booking.payed_booking.nil?
				if !@booking.is_session
				  if !@company.company_setting.online_cancelation_policy.nil?
				    ocp = @company.company_setting.online_cancelation_policy
				    if !ocp.cancelable
				      render json: { errors: "La empresa no permite la anulación de las reservas pagadas en línea." }, status: 422
			          return
				    else
				      #Revisar tiempos de modificación, tanto máximo como el mínimo específico para los pagados en línea

				      #Mínimo
				      book_start = DateTime.parse(@booking.start.to_s)
				      min_hours = (book_start-now)/(60*60)
				      min_hours = min_hours.to_i.abs

				      if min_hours >= ocp.min_hours.to_i
				        render json: { errors: "La empresa permite anulación de las reservas sólo " + ocp.min_hours + " horas después." }, status: 422
			            return
				      end

				      #Máximo
				      booking_creation = DateTime.parse(@booking.created_at.to_s)
				      minutes = (booking_creation.to_time - now.to_time)/(60)
				      hours = (booking_creation.to_time - now.to_time)/(60*60)
				      days = (booking_creation.to_time - now.to_time)/(60*60*24)
				      minutes = minutes.to_i.abs
				      hours = hours.to_i.abs
				      days = days.to_i.abs
				      weeks = days/7
				      months = days/30

				      #Obtener el máximo
				      num = ocp.cancel_max.to_i
				      if ocp.cancel_unit == TimeUnit.find_by_unit("Minutos").id
				        if minutes >= num
				          render json: { errors: "La empresa permite anulación de las reservas sólo hasta " + ocp.cancel_max + " " + ocp.cancel_unit + " antes." }, status: 422
			              return
				        end
				      elsif ocp.cancel_unit == TimeUnit.find_by_unit("Horas").id
				        if hours >= num
				          render json: { errors: "La empresa permite anulación de las reservas sólo hasta " + ocp.cancel_max + " " + ocp.cancel_unit + " antes." }, status: 422
			              return
				        end
				      elsif ocp.cancel_unit == TimeUnit.find_by_unit("Semanas").id
				        if weeks >= num
				          render json: { errors: "La empresa permite anulación de las reservas sólo hasta " + ocp.cancel_max + " " + ocp.cancel_unit + " antes." }, status: 422
			              return
				        end
				      elsif ocp.cancel_unit == TimeUnit.find_by_unit("Meses").id
				        if months >= num
				          render json: { errors: "La empresa permite anulación de las reservas sólo hasta " + ocp.cancel_max + " " + ocp.cancel_unit + " antes." }, status: 422
			              return
				        end
				      end

				    end
				  end
				end
			end

			status = @booking.status.id
			payed = @booking.payed
			is_booked = @booking.is_session_booked
			if !@booking.is_session
				status = Status.find_by(:name => 'Cancelado').id
				payed = false
			else
				is_booked = false
				@booking.user_session_confirmed = false
			    @booking.is_session_booked = false
			end

			if @booking.update(status_id: status, payed: payed, is_session_booked: is_booked)

				if !@booking.payed_booking.nil?
				  @booking.payed_booking.canceled = true
				  @booking.payed_booking.save
				end
				#flash[:notice] = "Reserva cancelada exitosamente."
				# BookingMailer.cancel_booking(@booking)
				@api_user ? user = @api_user.id : user = 0
				BookingHistory.create(booking_id: @booking.id, action: "Cancelada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)
			else
				render json: { errors: "Hubo un error cancelando tu reserva. Inténtalo nuevamente." }, status: 422
		        return
			end
		end

		def show
			if params[:id] && params[:access_token]
		  		@booking = Booking.find(params[:id])
		  		unless @booking.access_token == params[:access_token]
		  			render json: { errors: "Parámetros mal ingresados." }, status: 422
		        	return
		  		end

		  		@bookings_group = Booking.where(id: @booking.id)
		  		if @booking.trx_id.present?
		  			@bookings_group = Booking.where(trx_id: @booking.trx_id)
		  		elsif @booking.booking_group.present?
		  			@bookings_group = Booking.where(booking_group: @booking.booking_group, location_id: @booking.location_id)
		  		end

		  		@payment_info = ''
		  		if @booking.trx_id.present?
		  			@bookings_group = Booking.where(trx_id: @booking.trx_id)
		  			if PuntoPagosConfirmation.find_by(trx_id: @booking.trx_id)
		  				@punto_pagos = PuntoPagosConfirmation.find_by(trx_id: @booking.trx_id)
		  				@payment_info = {company_name: @booking.location.company.name, amount: @punto_pagos.amount, reference: @punto_pagos.trx_id, payment_date: @punto_pagos.approvement_date}
		  			elsif PayUNotification.find_by(reference_sale: @booking.trx_id)
		  				@pay_u = PayUNotification.find_by(trx_id: @booking.trx_id)
		  				@payment_info = {company_name: @booking.location.company.name, amount: @pay_u.value, reference: @pay_u.reference_sale, payment_date: @pay_u.transaction_date.strftime('%d-%m-%Y')}
		  			end
		  		elsif @booking.booking_group.present?
		  			@bookings_group = Booking.where(booking_group: @booking.booking_group, location_id: @booking.location_id)
		  		end
		  			
			else
				render json: { errors: "Parámetros mal ingresados." }, status: 422
		        return
		    end
		end

		def show_group
			if params[:bookings]

		  		@bookings = Booking.where(id: params[:ids])
		  	else
				render json: { errors: "Parámetros mal ingresados." }, status: 422
		        return
		    end
		end

		private

		def booking_params
		  params.require(:bookings).permit(bookings: [:service_id, :provider_id, :start, :end, :provider_lock, :price, :is_time_discount, :service_promo_id])
		end

		def editing_params
		  params.require(:booking).permit(:id, :service_provider_id, :start, :end)
		end

		def client_params
		  params.require(:client).permit(:name, :phone, :email, :notes, :mailing_option, :address, :identification_number, :deal_code)
		end
	  end
	end
  end
end