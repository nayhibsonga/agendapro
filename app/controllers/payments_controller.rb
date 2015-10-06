class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"
  load_and_authorize_resource

  respond_to :html, :json

  def index
    @payment = Payment.new
    @company_setting = current_user.company.company_setting
    @payments = Payment.where(company_id: current_user.company_id)
    respond_with(@payments)
  end

  def index_content
    @from = params[:from].blank? ? Date.today : Date.parse(params[:from])
    @to = params[:to].blank? ? Date.today : Date.parse(params[:to])
    @location_ids = params[:location_ids] ? params[:location_ids].split(',') : Location.where(company_id: current_user.company_id).accessible_by(current_ability).pluck(:id)
    @payment_method_ids = params[:payment_method_ids] ? params[:payment_method_ids].split(',') : PaymentMethod.all.pluck(:id)

    @payments = Payment.where(payment_date: @from..@to, location_id: @location_ids, payment_method_id: @payment_method_ids).order(:payment_date)

    render "_index_content", layout: false
  end

  def show
    respond_with(@payment)
  end

  def new
    @payment = Payment.new
    respond_with(@payment)
  end

  def edit
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.company_id = current_user.company_id
    @payment.save
    respond_with(@payment)
  end

  def update
    @payment_products = Payment.find(params[:id]).payment_products
    @payment_products.each do |payment_product|
      payment_product.payment_id = nil
      payment_product.save
    end
    @payment = Payment.find(params[:id])
    respond_to do |format|
      if @payment.update(payment_params)
        @payment_products.destroy_all
        format.html { redirect_to payments_path, notice: 'Pago actualizado exitosamente.' }
        format.json { render :json => @payment }
      else
        @payment_products.each do |payment_product|
          payment_product.payment_id = @payment.id
          payment_product.save
        end
        format.html { redirect_to payments_path, alert: 'No se pudo guardar el pago.' }
        format.json { render :json => { :errors => @payment.errors.full_messages }, :status => 422 }
      end
    end
  end

  def destroy
    @payment.destroy
    respond_with(@payment)
  end

  def booking_payment
    weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
    if !params[:booking_id].blank?
      @booking = Booking.find(params[:booking_id])
      @client = @booking.client
      @location = @booking.location
      if @booking.payment
        @payment = @booking.payment
        @elegible_bookings = @payment.bookings.where.not(is_session: true)
        @elegible_sessions = @payment.bookings.where.not(is_session: false, session_booking_id: nil)
        @past_bookings = Booking.where.not(is_session: true, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where.not(id: @payment.bookings.pluck(:id)).order(start: :desc).limit(100).pluck(:id)
        @past_sessions = Booking.where.not(is_session: false, session_booking_id: nil, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where.not(id: @payment.bookings).order(start: :desc).limit(100).pluck(:id)
      else
        @payment = Payment.new
        @elegible_bookings = Booking.where.not(is_session: true, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where(start: @booking.start.beginning_of_day..@booking.start.end_of_day).order(:start)
        @elegible_sessions = Booking.where.not(is_session: false, session_booking_id: nil, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where(start: @booking.start.beginning_of_day..@booking.start.end_of_day).order(:start)
        @past_bookings = Booking.where.not(is_session: true, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where.not(id: @elegible_bookings).order(start: :desc).limit(100).pluck(:id)
        @past_sessions = Booking.where.not(is_session: false, session_booking_id: nil, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where.not(id: @elegible_sessions).order(start: :desc).limit(100).pluck(:id)
      end
    elsif !params[:client_id].blank? && !params[:location_id].blank?
      @client = Client.find(params[:client_id])
      @location = Location.find(params[:location_id])
      @payment = Payment.new
      @elegible_bookings = Booking.where.not(is_session: true, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where(start: (Time.now - eval(ENV["TIME_ZONE_OFFSET"])).beginning_of_day..(Time.now - eval(ENV["TIME_ZONE_OFFSET"])).end_of_day).order(:start)
      @past_bookings = Booking.where.not(is_session: true, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where.not(id: @elegible_bookings).order(start: :desc).limit(100).pluck(:id)
      @elegible_sessions = Booking.where.not(is_session: false, session_booking_id: nil, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where(start: (Time.now - eval(ENV["TIME_ZONE_OFFSET"])).beginning_of_day..(Time.now - eval(ENV["TIME_ZONE_OFFSET"])).end_of_day).order(:start)
      @past_sessions = Booking.where.not(is_session: false, session_booking_id: nil, status_id: Status.find_by_name("Cancelado")).where(location_id: @location.id, client_id: @client.id, payment_id: nil).where.not(id: @elegible_sessions).order(start: :desc).limit(100).pluck(:id)
    else

    end

    @payment_bookings = @payment.id ? @payment.bookings.pluck(:id) : (@elegible_bookings.where(payment_id: nil).pluck(:id) + @elegible_sessions.where(payment_id: nil).pluck(:id)).uniq
    @bookings = []
    @elegible_bookings.each do |b|
      @bookings.push( { booking: b, booking_checked: @payment_bookings.include?(b.id), booking_service: b.service.name, booking_provider: b.service_provider.public_name, booking_date: weekdays[b.start.wday] + ' ' + b.start.strftime('%d-%m-%Y'), booking_time: b.start.strftime('%R'), booking_price: b.service.price.round(0) } )
      @past_bookings = @past_bookings - [b.id]
    end


    @sessions = []
    @elegible_sessions.pluck(:session_booking_id).uniq.each do |sb|
      session_booking = SessionBooking.find(sb)
      @past_sessions = @past_sessions - session_booking.bookings.pluck(:id)
      @payment_bookings = (@payment_bookings + session_booking.bookings.pluck(:id)).uniq
      @sessions.push( { session_booking: session_booking, session_booking_ids: session_booking.bookings.pluck(:id).inspect, session_checked: (@payment_bookings & session_booking.bookings.pluck(:id)).present?, session_service: session_booking.bookings.first.service.name, session_normal: session_booking.bookings.first.service.price.round(0), session_price: session_booking.bookings.first.price, session_discount: session_booking.bookings.first.discount, session_count: session_booking.bookings.count } )
    end

    @products = @payment.payment_products

    render :json => {payment: @payment, client: @client, bookings: @bookings, sessions: @sessions, products: @products, past_bookings: @past_bookings, past_sessions: @past_sessions }
  end

  def load_payment

    @payment = nil

    errors = []

    #Check if there's a payment_id and find the payment
    if !params[:payment_id].blank?
      @payment = Payment.find(params[:payment_id])
      if @payment.nil?
        errors << "No existe un pago con id " + params[:payment_id].to_s
        render :json => {errors: errors}
        return
      end
    end

    #Check if there's a booking_id and get it's payment
    if !params[:booking_id].blank?

      @booking = Booking.find(params[:booking_id])

      if @booking.nil?
        errors << "No existe una reserva con id " + params[:booking_id].to_s
        render :json => {errors: errors}
        return
      end

      @payment = @booking.payment

      if @payment.nil?
        errors << "No existe un pago asociado a la reserva con id " + params[:booking_id].to_s
        render :json => {errors: errors}
        return
      end

    end



    @bookings = []
    @payment.bookings.each do |booking|
      @bookings << {id: booking.id, service_name: booking.service.name, service_price: booking.service.price, discount: booking.discount, price: booking.price, list_price: booking.list_price}
    end

    @mock_bookings = []
    @payment.mock_bookings.each do |mock_booking|
      service_id = -1
      service_name = "Ninguno"
      provider_id = -1
      provider_name = "Ninguno"

      if !mock_booking.service_id.nil?
        service_id = mock_booking.service_id
        service_name = mock_booking.service.name
      end

      if !mock_booking.service_provider_id.nil?
        provider_id = mock_booking.service_provider_id
        provider_name = mock_booking.service_provider.public_name
      end

      @mock_bookings << {id: mock_booking.id, service_id: service_id, service_name: service_name, provider_id: provider_id, provider_name: provider_name, price: mock_booking.price, discount: mock_booking.discount}

    end

    @payment_products = []
    @payment.payment_products.each do |payment_product|
      @payment_products << {id: payment_product.product.id, name: payment_product.product.name, quantity: payment_product.quantity, price: payment_product.price, discount: payment_product.discount, seller: payment_product.seller_id.to_s + '_' + payment_product.seller_type.to_s}
    end

    @receipts = @payment.receipts

    render :json => {payment: @payment, payment_products: @payment_products, bookings: @bookings, mock_bookings: @mock_bookings, receipts: @receipts, errors: errors}

  end

  def past_bookings
    weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
    @full_past_bookings = Booking.where(id: params[:booking_ids]).order(start: :desc)
    @past_bookings = []
    @full_past_bookings.each do |b|
      @past_bookings.push({ booking: b, booking_checked: true, booking_service: b.service.name, booking_provider: b.service_provider.public_name, booking_date: weekdays[b.start.wday] + ' ' + b.start.strftime('%d-%m-%Y'), booking_time: b.start.strftime('%R'), booking_price: b.service.price.round(0) })
    end
    render :json => { past_bookings: @past_bookings }
  end

  def past_sessions
    weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
    @full_past_sessions = Booking.where(id: params[:booking_ids]).where.not(session_booking_id: nil).order(start: :desc)
    @past_sessions = []
    @full_past_sessions.pluck(:session_booking_id).uniq.each do |sb|
      session_booking = SessionBooking.find(sb)
      @past_sessions.push( { session_booking: session_booking, session_booking_ids: session_booking.bookings.pluck(:id).inspect, session_checked: true, session_service: session_booking.bookings.first.service.name, session_normal: session_booking.bookings.first.service.price.round(0), session_price: session_booking.bookings.first.price, session_discount: session_booking.bookings.first.discount, session_count: session_booking.bookings.count } )
    end

    render :json => { past_sessions: @past_sessions }
  end

  def client_bookings
    weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']

    #Treat session bookings as a normal booking. Worry about the price afterwards.
    #Only leave out those that haven't been booked yet.
    #IMPORTANT: Leave out bookings that are already associated to a payment.

    @full_past_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where.not('is_session = true and is_session_booked = false').where('payment_id is null').where(client_id: params[:client_id], location_id: params[:location_id], payment_id: nil).order(start: :desc).limit(100)
    @past_bookings = []
    @full_past_bookings.each do |b|

      #Dummy amount for services whitout sessions
      sessions_amount = 1
      session_number = 1
      if !b.session_booking_id.nil?

        sessions_amount = b.session_booking.sessions_amount
        Booking.where(:session_booking_id => b.session_booking.id, :is_session_booked => true).order('start asc').each do |u|
          if u.id == b.id
            break
          else
            session_number = session_number + 1
          end
        end

      end

      @past_bookings.push({ booking: b, booking_checked: true, booking_service: b.service.name, booking_provider: b.service_provider.public_name, booking_date: weekdays[b.start.wday] + ' ' + b.start.strftime('%d-%m-%Y'), booking_time: b.start.strftime('%R'), booking_datetime: b.start.strftime('%d/%m/%Y') + ' - ' + b.start.strftime('%R'), booking_price: b.price, sessions_amount: sessions_amount, session_number: session_number })
    end
    render :json => { past_bookings: @past_bookings }
  end

  def client_sessions
    weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
    @full_past_sessions = Booking.where.not(is_session: false, session_booking_id: nil, status_id: Status.find_by_name("Cancelado")).where(client_id: params[:client_id], location_id: params[:location_id], payment_id: nil).order(start: :desc).limit(100)
    @past_sessions = []
    @full_past_sessions.pluck(:session_booking_id).uniq.each do |sb|
      session_booking = SessionBooking.find(sb)
      @past_sessions.push( { session_booking: session_booking, session_booking_ids: session_booking.bookings.pluck(:id).inspect, session_checked: true, session_service: session_booking.bookings.first.service.name, session_normal: session_booking.bookings.first.service.price.round(0), session_price: session_booking.bookings.first.price, session_discount: session_booking.bookings.first.discount, session_count: session_booking.bookings.count } )
    end
    render :json => { past_sessions: @past_sessions }
  end



  def create_new_payment

    @json_response = []
    @errors = []

    #Find location
    location = Location.find(params[:location_id])

    payment = Payment.new

    #Find or create a client (update if necessary)
    

    if params[:set_client] == "1"
      
      client = Client.new
      
      if params[:client_id] && !params[:client_id].blank?
        client = Client.find(params[:client_id])
      end
        
      client.first_name = params[:client_first_name]
      client.last_name = params[:client_last_name]
      client.email = params[:client_email]
      client.phone = params[:client_phone]
      client.gender = params[:client_gender]
      client.company_id = location.company_id
      
      if client.save
        payment.client_id = client.id
      else
        @errors << "No se pudo guardar al cliente"
      end   

    else
      payment.client_id = nil
    end

    

    payment.payment_method_id = params[:payment_method_id]

    payment.cashier_id = params[:cashier_id]

    if params[:method_number].blank?
      payment.payment_method_number = ""
    else
      payment.payment_method_number = params[:method_number]
    end

    if payment.payment_method_id == PaymentMethod.find_by_name("Tarjeta de Crédito").id
      payment.payment_method_type_id = params[:pay_method_type]
    end

    if payment.payment_method_id == PaymentMethod.find_by_name("Cheque").id
      payment.bank_id = params[:payment_bank]
    end

    if payment.payment_method_id == PaymentMethod.find_by_name("Otro").id
      payment.company_payment_method_id = params[:payment_other_method_type]
    end

    payment.installments = params[:dues_number]
    payment.payed = true
    payment.payment_date = params[:payment_date].to_date

    #payment.notes = params[:payment_notes]
    payment.notes = ""
    payment.location_id = params[:location_id]

    payment.paid_amount = params[:paid_amount]
    payment.amount = params[:cost]
    payment.change_amount = params[:change_amount]
    #For real amount, discount and change, recalculate costs.

    past_bookings = JSON.parse(params[:past_bookings], symbolize_names: true)
    new_bookings = JSON.parse(params[:new_bookings], symbolize_names: true)
    products = JSON.parse(params[:products], symbolize_names: true)
    receipts = JSON.parse(params[:receipts], symbolize_names: true)

    @mockBookings = []
    @bookings = []
    @paymentProducts = []


    receipts.each do |receipt|
      new_receipt = Receipt.new
      new_receipt.receipt_type_id = receipt[:receipt_type_id]
      new_receipt.amount = receipt[:amount]
      new_receipt.date = receipt[:date]
      new_receipt.notes = receipt[:notes]
      new_receipt.number = receipt[:number]

      receipt_items = receipt[:items]

      #Check for it's items and add them to their corresponding array
      receipt_items.each do |item|
        if item[:item_type] == "new_booking"

          new_booking = item
          mock_booking = MockBooking.new
          if new_booking[:service_id] != -1 && new_booking[:service_id] != "-1"
            mock_booking.service_id = new_booking[:service_id]
          end
          if new_booking[:provider_id] != -1 && new_booking[:provider_id] != "-1"
            mock_booking.service_provider_id = new_booking[:provider_id]
          end
          mock_booking.price = new_booking[:price]
          mock_booking.discount = new_booking[:discount]
          mock_booking.client_id = payment.client_id
          @mockBookings << mock_booking

          new_receipt.mock_bookings << mock_booking

        elsif item[:item_type] == "past_booking"
          past_booking = item
          booking = Booking.find(past_booking[:id])
          #booking.list_price = past_booking[:]
          booking.discount = past_booking[:discount]
          booking.price = (past_booking[:list_price].to_f*(100-booking.discount)/100).round(1)

          @bookings << booking
          new_receipt.bookings << booking
        else
          product = item
          payment_product = PaymentProduct.new
          payment_product.product_id = product[:id]
          payment_product.price = product[:price]
          payment_product.discount = product[:discount]
          payment_product.quantity = product[:quantity]

          seller = product[:seller].split("_")
          payment_product.seller_id = seller[0]
          payment_product.seller_type = seller[1]

          new_receipt.payment_products << payment_product

          @paymentProducts << payment_product
        end
      end

      new_receipt.payment = payment
      
      if new_receipt.save
        @json_response[0] = "ok"
      else
        @json_response[0] = "error"
        @errors << new_receipt.errors
      end

    end

    payment.bookings = @bookings
    payment.mock_bookings = @mockBookings
    payment.payment_products = @paymentProducts

    if payment.save
      @json_response[0] = "ok"
    else
      @json_response[0] = "error"
      @errors << payment.errors
    end

    if @json_response[0] == "ok"
      @json_response << payment
      @json_response[2] = []
      payment.receipts.each do |receipt|
        receipt_detail = []
        receipt_detail << receipt.id
        receipt_detail << receipt.receipt_type.name
        receipt_detail << receipt.number
        @json_response[2] << receipt_detail
      end
    else
      @json_response << @errors
    end

    render :json => @json_response

  end


  #
  # Almost equal to create_new_payment.
  # Just deletes/disassociates items and reconstructs them.
  # Obviously, updates all params concerning the payment (client, cashier, date, payment_method, amount, etc.)
  #

  def update_payment

    @json_response = []
    @errors = []

    #Find location
    location = Location.find(params[:location_id])

    payment = Payment.find(params[:payment_id])

    #Find or create a client (update if necessary)
    if params[:set_client] == "1"
      
      client = Client.new
      
      if params[:client_id] && !params[:client_id].blank?
        client = Client.find(params[:client_id])
      end
        
      client.first_name = params[:client_first_name]
      client.last_name = params[:client_last_name]
      client.email = params[:client_email]
      client.phone = params[:client_phone]
      client.gender = params[:client_gender]
      client.company_id = location.company_id
      
      if client.save
        payment.client_id = client.id
      else
        @errors << "No se pudo guardar al cliente"
      end   

    else
      payment.client_id = nil
    end

    

    payment.payment_method_id = params[:payment_method_id]

    payment.cashier_id = params[:cashier_id]

    if params[:method_number].blank?
      payment.payment_method_number = ""
    else
      payment.payment_method_number = params[:method_number]
    end

    if payment.payment_method_id == PaymentMethod.find_by_name("Tarjeta de Crédito").id
      payment.payment_method_type_id = params[:pay_method_type]
    end

    if payment.payment_method_id == PaymentMethod.find_by_name("Cheque").id
      payment.bank_id = params[:payment_bank]
    end

    if payment.payment_method_id == PaymentMethod.find_by_name("Otro").id
      payment.company_payment_method_id = params[:payment_other_method_type]
    end

    payment.installments = params[:dues_number]
    payment.payed = true
    payment.payment_date = params[:payment_date].to_date

    #payment.notes = params[:payment_notes]
    payment.notes = ""
    payment.location_id = params[:location_id]

    payment.paid_amount = params[:paid_amount]
    payment.amount = params[:cost]
    payment.change_amount = params[:change_amount]
    #For real amount, discount and change, recalculate costs.

    past_bookings = JSON.parse(params[:past_bookings], symbolize_names: true)
    new_bookings = JSON.parse(params[:new_bookings], symbolize_names: true)
    products = JSON.parse(params[:products], symbolize_names: true)
    receipts = JSON.parse(params[:receipts], symbolize_names: true)

    @mockBookings = []
    @bookings = []
    @paymentProducts = []

    #
    # UPDATE
    #
    # Receipts should be deleted and reconstructed.
    # PaymentProducts should be deleted and reconstructed.
    # MockBookings should be deleted and reconstructed.
    # Booking should be disasociated from payment and then reassociated with new params.
    #

    payment.mock_bookings.each do |mock_booking|
      mock_booking.delete
    end

    payment.payment_products.each do |payment_product|
      payment_product.delete
    end

    old_bookings = payment.bookings

    old_bookings.each do |booking|
      booking.receipt_id = nil
      booking.payment_id = nil
      booking.save
    end

    payment.receipts.each do |receipt|
      receipt.delete
    end


    #
    # Deletes and disassociations done.
    # Now reconstruct
    #

    receipts.each do |receipt|
      new_receipt = Receipt.new
      new_receipt.receipt_type_id = receipt[:receipt_type_id]
      new_receipt.amount = receipt[:amount]
      new_receipt.date = receipt[:date]
      new_receipt.notes = receipt[:notes]
      new_receipt.number = receipt[:number]

      receipt_items = receipt[:items]

      #Check for it's items and add them to their corresponding array
      receipt_items.each do |item|
        if item[:item_type] == "new_booking"

          new_booking = item
          mock_booking = MockBooking.new
          if new_booking[:service_id] != -1 && new_booking[:service_id] != "-1"
            mock_booking.service_id = new_booking[:service_id]
          end
          if new_booking[:provider_id] != -1 && new_booking[:provider_id] != "-1"
            mock_booking.service_provider_id = new_booking[:provider_id]
          end
          mock_booking.price = new_booking[:price]
          mock_booking.discount = new_booking[:discount]
          mock_booking.client_id = payment.client_id
          @mockBookings << mock_booking

          new_receipt.mock_bookings << mock_booking

        elsif item[:item_type] == "past_booking"
          past_booking = item
          booking = Booking.find(past_booking[:id])
          #booking.list_price = past_booking[:]
          booking.discount = past_booking[:discount]
          booking.price = (past_booking[:list_price].to_f*(100-booking.discount)/100).round(2)
          booking.client_id = client.id

          @bookings << booking
          booking.payment = payment
          new_receipt.bookings << booking
        else
          product = item
          payment_product = PaymentProduct.new
          payment_product.product_id = product[:id]
          payment_product.price = product[:price]
          payment_product.discount = product[:discount]
          payment_product.quantity = product[:quantity]

          seller = product[:seller].split("_")
          payment_product.seller_id = seller[0]
          payment_product.seller_type = seller[1]

          new_receipt.payment_products << payment_product

          @paymentProducts << payment_product
        end
      end

      new_receipt.payment = payment
      
      if new_receipt.save
        @json_response[0] = "ok"
      else
        @json_response[0] = "error"
        @errors << new_receipt.errors
      end

    end

    payment.bookings = @bookings
    payment.mock_bookings = @mockBookings
    payment.payment_products = @paymentProducts

    if @errors.length == 0
      if payment.save
        @json_response[0] = "ok"
      else
        @json_response[0] = "error"
        @errors << payment.errors
      end
    else
      @json_response[0] = "error"
    end

    if @json_response[0] == "ok"
      @json_response << payment
      @json_response[2] = []
      payment.receipts.each do |receipt|
        receipt_detail = []
        receipt_detail << receipt.id
        receipt_detail << receipt.receipt_type.name
        receipt_detail << receipt.number
        @json_response[2] << receipt_detail
      end
    else
      @json_response << @errors
    end

    render :json => @json_response

  end

  def receipt_pdf
    
    @receipt = Receipt.find(params[:receipt_id])
    @filename = @receipt.receipt_type.name + "_" + @receipt.number.to_s

    date = DateTime.now

    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReceiptsPdf.new(@receipt.id)
        send_data pdf.render, filename: @filename + "_" + date.to_s[0,10] + '.pdf', type: 'application/pdf'
      end
    end
  end

  def payment_pdf
    @payment = Payment.find(params[:payment_id])
    @filename = "Resumen de pago "
    date = DateTime.now

    respond_to do |format|
      format.html
      format.pdf do
        pdf = PaymentsPdf.new(@payment.id)
        send_data pdf.render, filename: @filename + "_" + date.to_s[0,10] + '.pdf', type: 'application/pdf'
      end
    end

  end

  def send_receipts_email

    @payment = Payment.find(params[:payment_id])
    @json_response = []
    
    if @payment.send_receipts_email(params[:emails])
      @json_response << "ok"
      @json_response << @payment
    else
      @json_response << "error"
      @json_response << ""
    end

    render :json => @json_response

  end

  def get_receipts
    @payment = Payment.find(params[:payment_id])
    @receipts = []
    @payment.receipts.each do |receipt|
        receipt_detail = []
        receipt_detail << receipt.id
        receipt_detail << receipt.receipt_type.name
        receipt_detail << receipt.number
        @receipts << receipt_detail
    end
    render :json => @receipts
  end

  #
  # Returns payment's cashier, client and date
  #
  def get_intro_info

    @payment = Payment.find(params[:payment_id])
    @client = @payment.client
    @cashier = @payment.cashier

    render :json => {payment: @payment, client: @client, cashier: @cashier}

  end

  #
  # Updates payment's cashier and client info.
  # Updates client_id for each mock_booking.
  #
  def save_intro_info

    json_response = []
    errors = []

    payment = Payment.find(params[:payment_id])

    if params[:set_client] == "1"
      
      client = Client.new
      
      if params[:client_id] && !params[:client_id].blank?
        client = Client.find(params[:client_id])
      end
        
      client.first_name = params[:client_first_name]
      client.last_name = params[:client_last_name]
      client.email = params[:client_email]
      client.phone = params[:client_phone]
      client.gender = params[:client_gender]
      client.company_id = payment.location.company_id
      
      if client.save
        payment.client_id = client.id
      else
        errors << "No se pudo guardar al cliente"
      end   

    else
      payment.client_id = nil
    end

    payment.cashier_id = params[:cashier_id]
    payment.payment_date = params[:payment_date].to_date

    payment.mock_bookings.each do |mock_booking|
      mock_booking.client_id = payment.client_id
      if !mock_booking.save
        errors << "No se pudo guardar un servicio"
      end
    end

    payment.bookings.each do |booking|
      booking.client_id = payment.client_id
      if !booking.save
        errors << "No se pudo guardar un servicio"
      end
    end

    if errors.length == 0
      if payment.save
        json_response << "ok"
        json_response << payment
      else
        json_response << "error"
        errors << payment.errors
        json_response << errors
      end
    else
      json_response << "error"
      json_response << errors
    end

    render :json => json_response

  end

  #Responds if a booking has a payment or not
  def check_booking_payment
    
    booking = Booking.find(params[:booking_id])
    json_response = []

    if booking.payment_id.nil?
      json_response << "no"
    else
      json_response << "yes"
      json_response << booking.payment
    end

    render :json => json_response

  end

  #Returns a formatted booking to prefill a new payment
  def get_formatted_booking
    booking = Booking.find(params[:booking_id])
    book = {id: booking.id, service_name: booking.service.name, service_price: booking.service.price, discount: booking.discount, price: booking.price, list_price: booking.list_price, location_id: booking.location_id}
    client = booking.client
    json_response = {booking: book, client: client}
    render :json => json_response
  end

  def delete_payment

    @payment = Payment.find(params[:payment_id])
    errors = []
    json_response = []

    @payment.payment_products.each do |payment_product|
      if payment_product.delete
      else
        errors << payment_product.errors
      end
    end

    @payment.mock_bookings.each do |mock_booking|
      if mock_booking.delete
      else
        errors << mock_booking.errors
      end
    end

    @payment.bookings.each do |booking|
      booking.payment_id = nil
      booking.receipt_id = nil
      if booking.save
      else
        errors << booking.errors
      end
    end

    @payment.receipts.each do |receipt|
      if receipt.delete
      else
        errors << receipt.errors
      end
    end

    if errors.length == 0
      if @payment.delete
        json_response << "ok"
      else
        json_response << "error"
        errors << @payment.errors
        json_response << errors
      end
    else
      json_response << "error"
      json_response << errors
    end

    render :json => json_response

  end

  def day_payments

  end

  def commissions

    @locations = []
    @service_providers = []
    @service_commissions = []
    @service_categories = []

    if current_user.role_id == Role.find_by_name("Administrador General").id
      @locations = current_user.company.locations.where(:active => true).order(name: :asc)
      @service_providers = current_user.company.service_providers
      @service_categories = current_user.company.service_categories
      @service_commissions = ServiceCommission.where(service_provider_id: @service_providers.pluck(:id))
    elsif current_user.role_id == Role.find_by_name("Administrador Local").id
      @locations = current_user.locations.where(:active => true).order(name: :asc)
      @service_providers = ServiceProvider.where(location_id: @locations.pluck(:id))
      @service_categories = ServiceCategory.where(service_id: Service.where(service_provider_id: @service_providers.pluck(:id)))
      @service_commissions = ServiceCommission.where(service_provider_id: @service_providers.pluck(:id))
    end

  end

  #Returns a list of providers and service_commissions for given service
  def service_commissions

    service = Service.find(params[:service_id])

    providers = []

    if !params[:location_id].blank?
      providers = service.service_providers.where(location_id: params[:location_id])
    else
      providers = service.service_providers
    end

    service_commissions = []

    providers.each do |provider|
      service_commission = ServiceCommission.new
      if ServiceCommission.where(:service_id => service.id, :service_provider_id => provider.id).count > 0
        service_commission = ServiceCommission.where(:service_id => service.id, :service_provider_id => provider.id).first
      else
        service_commission.service_id = service.id
        service_commission.service_provider_id = provider.id
        service_commission.amount = service.comission_value
        if service.comission_option == 0
          service_commission.is_percent = true
        else
          service_commission.is_percent = false
        end
        service_commission.save
      end
      service_commissions << {service_id: service.id, service_name: service.name, provider_id: provider.id, provider_name: provider.public_name, amount: service_commission.amount, is_percent: service_commission.is_percent}
    end

    render :json => service_commissions

  end

  #Returns a list of services and service_commissions for given provider
  def provider_commissions

    provider = ServiceProvider.find(params[:provider_id])

    services = []

    services = provider.services

    service_commissions = []

    services.each do |service|
      service_commission = ServiceCommission.new
      if ServiceCommission.where(:service_id => service.id, :service_provider_id => provider.id).count > 0
        service_commission = ServiceCommission.where(:service_id => service.id, :service_provider_id => provider.id).first
      else
        service_commission.service_id = service.id
        service_commission.service_provider_id = provider.id
        service_commission.amount = service.comission_value
        if service.comission_option == 0
          service_commission.is_percent = true
        else
          service_commission.is_percent = false
        end
        service_commission.save
      end
      service_commissions << {service_id: service.id, service_name: service.name, provider_id: provider.id, provider_name: provider.public_name, amount: service_commission.amount, is_percent: service_commission.is_percent}
    end

    render :json => service_commissions

  end

  private
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(:amount, :receipt_type_id, :receipt_number, :payment_method_id, :payment_method_number, :payment_method_type_id, :installments, :payed, :payment_date, :bank_id, :company_payment_method_id, :location_id, :client_id, :notes, booking_ids: [], bookings_attributes: [:id, :discount, :price], payment_products_attributes: [:product_id, :quantity, :discount, :price])
    end
end
