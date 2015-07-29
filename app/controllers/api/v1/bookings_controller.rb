module Api
  module V1
  	class BookingsController < V1Controller
  	before_filter :parse_booking_params, only: [:book_service]
      
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

	    puts params[:bookings].inspect
	    booking_data = JSON.parse(params[:bookings].inspect)

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

	    if params[:comment].blank?
	      params[:comment] = ''
	    end

	    if params[:address] && !params[:address].empty?
	      params[:comment] += ' - Dirección del cliente (donde se debe realizar el servicio): ' + params[:address]
	    end

	    #booking_data = JSON.parse(params[:bookings], symbolize_names: true)
	    #is_session_booking = booking_data[0].has_sessions

	    deal = nil

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
	        if @mobile_user
	          @session_booking.user_id = current_user.id
	        end
	        #@session_booking.sessions_taken = booking_data.size
	        @session_booking.save
	      end
	    end

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

	      if @mobile_user
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
	        if @has_session_booking
	          final_price = num_amount
	        end
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
	          @mobile_user ? user = @mobile_user.id : user = 0
	          BookingHistory.create(booking_id: @booking.id, action: "Creada por Cliente", start: @booking.start, status_id: @booking.status_id, service_id: @booking.service_id, service_provider_id: @booking.service_provider_id, user_id: user, notes: @booking.notes, company_comment: @booking.company_comment)
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
	            @mobile_user ? user = @mobile_user.id : user = 0
	            BookingHistory.create(booking_id: booking.id, action: "Creada por Cliente", start: booking.start, status_id: booking.status_id, service_id: booking.service_id, service_provider_id: booking.service_provider_id, user_id: user, notes: booking.notes, company_comment: booking.company_comment)

	            if first_booking.nil?
	              first_booking = booking
	            end

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
	                @mobile_user ? user = @mobile_user.id : user = 0
	                BookingHistory.create(booking_id: new_booking.id, action: "Creada por Cliente", start: new_booking.start, status_id: new_booking.status_id, service_id: new_booking.service_id, service_provider_id: new_booking.service_provider_id, user_id: user, notes: new_booking.notes, company_comment: new_booking.company_comment)
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
	            @mobile_user ? user = @mobile_user.id : user = 0
	            BookingHistory.create(booking_id: new_booking.id, action: "Creada por Cliente", start: new_booking.start, status_id: new_booking.status_id, service_id: new_booking.service_id, service_provider_id: new_booking.service_provider_id, user_id: user, notes: new_booking.notes, company_comment: new_booking.company_comment)
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


	    if @errors.length > 0 and booking_data.length > 0
	      books = []
	      @bookings.each do |b|
	        if !b.id.nil?
	          books << b
	        end
	      end
	      render json: { errors: @errors }, status: 422
	    end

	    if @bookings.length > 1
	      if @session_booking.nil?
	        Booking.send_multiple_booking_mail(@location_id, booking_group)
	      else
	        @session_booking.send_sessions_booking_mail
	      end
	    end

	  end

	  private

	  def parse_booking_params
	  	raw_params = booking_parms

	  	nameArray = []
        nameArray = raw_params[:name].split(' ') unless raw_params[:name].blank?

        first_name = ''
        last_name = ''

        if nameArray.length == 0

        elsif nameArray.length == 1
          first_name = nameArray[0] unless nameArray[0].blank?
        elsif nameArray.length == 2
          first_name = nameArray[0] unless nameArray[0].blank?
          last_name = nameArray[1] unless nameArray[1].blank?
        elsif nameArray.length == 3
          first_name = nameArray[0] unless nameArray[0].blank?
          last_name = nameArray[1] + ' ' + nameArray[2]
        else 
          first_name = nameArray[0] + ' ' + nameArray[1]
          last_name = ''
          (2..nameArray.length - 1).each do |i|
            last_name += nameArray[i]+' '
          end
          strLen = last_name.length
          last_name = last_name[0..strLen-1]
          last_name = last_name unless last_name.blank?
        end

	  	params[:service] = raw_params[:service_id]
		params[:provider] = raw_params[:service_provider_id]
		params[:start] = raw_params[:start]
		params[:end] = raw_params[:end]
		params[:origin] = true
		params[:location] = ServiceProvider.find(params[:provider]).location_id
		params[:provider_lock] = raw_params[:provider_lock]
		params[:has_sessions] = Service.find(params[:service]).has_sessions
		params[:bookings] = []
		bookings_hash = { :start => params[:start], :end => params[:end], :provider => params[:provider], :provider_lock => params[:provider_lock], :service => params[:service], :price => raw_params[:price] }
		params[:bookings].push(bookings_hash)
		params[:firstName] = first_name
		params[:lastName] = last_name
		params[:user] = { :full_name => raw_params[:name] }
		params[:email] = raw_params[:email]
		params[:phone] = raw_params[:phone]
		params[:comment] = raw_params[:notes]
		params[:payment] = 0

	  end

	  def booking_parms
	  	params.require(:booking).permit(:service_id, :service_provider_id, :start, :end, :provider_lock, :price, :name, :phone, :email, :notes)
	  end

  	end
  end
end