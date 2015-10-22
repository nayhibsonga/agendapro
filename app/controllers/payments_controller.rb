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

    @payment_method_ids = []
    @company_payment_method_ids = []
    if params[:payment_method_ids].blank?
      @payment_method_ids = PaymentMethod.all.pluck(:id)
      @company_payment_method_ids = CompanyPaymentMethod.where(company_id: current_user.company_id).pluck(:id)
    else
      method_ids_arr = params[:payment_method_ids].split(",")
      method_ids_arr.each do |method_str|
        method_arr = method_str.split("_")
        if method_arr[0] == "0"
          @payment_method_ids << method_arr[1].to_i
        else
          @company_payment_method_ids << method_arr[1].to_i
        end
      end
    end

    @payments = Payment.where(payment_date: @from..@to, location_id: @location_ids).where(id: PaymentTransaction.where('(payment_method_id in (?) or company_payment_method_id in (?))', @payment_method_ids, @company_payment_method_ids).pluck(:payment_id)).order(:payment_date)

    @products_sum = 0.0
    @products_average_discount = 0.0
    @products_total = 0
    @products_discount = 0

    @payments.each do |payment|
      payment.payment_products.each do |payment_product|
        @products_total += payment_product.quantity
        @products_sum += payment_product.price * payment_product.quantity
        @products_discount += payment_product.discount
      end
    end

    @internal_sales = InternalSale.where(location_id: @location_ids)

    @internal_sales_sum = 0.0
    @internal_sales_total = 0
    @internal_sales_discount = 0

    @internal_sales.each do |internal_sale|
      @products_total += internal_sale.quantity
      @products_sum += internal_sale.price*internal_sale.quantity
      @products_discount += internal_sale.discount
      @internal_sales_total += 1
      @internal_sales_sum += internal_sale.price*internal_sale.quantity
      @internal_sales_discount += internal_sale.discount
    end

    if @products_total > 0
      @products_average_discount = (@products_discount/@products_total).round(2)
    else
      @products_average_discount = 0
    end

    products_total_price = 0
    products_actual_price = 0

    @payments.each do |payment|
      payment.payment_products.each do |payment_product|
        products_total_price += payment_product.list_price * payment_product.quantity
        products_actual_price += payment_product.price * payment_product.quantity
      end
    end

    @internal_sales.each do |internal_sale|
      products_total_price += internal_sale.quantity*internal_sale.list_price
      products_actual_price += internal_sale.quantity*internal_sale.price
    end

    logger.debug "Total: " + products_total_price.to_s
    logger.debug "Pagado: " + products_actual_price.to_s

    @products_actual_discount = ((1 - (products_actual_price/products_total_price))*100).round(1)

    logger.debug "Descuento: " + @products_actual_discount.to_s + "%"

    @payments_sum = @payments.sum(:amount) + @internal_sales_sum
    @payments_discount = @payments.sum(:discount) + @internal_sales_discount
    @payments_total = @payments.count + @internal_sales_total
    @payments_average_discount = 0
    if @payments_total > 0
      @payments_average_discount = (@payments_discount/@payments_total).round(2)
    end


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

    payment.cashier_id = params[:cashier_id]
    payment.company_id = current_user.company.id

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
    transactions = JSON.parse(params[:transactions], symbolize_names: true)

    @mockBookings = []
    @bookings = []
    @paymentProducts = []

    #Save payment before
    unless payment.save
      @json_response[0] = "error"
      @errors << payment.errors
      render :json => @json_response
      return
    end

    check_method_id = PaymentMethod.find_by_name("Cheque").id
    cash_method_id = PaymentMethod.find_by_name("Efectivo").id
    credit_card_method_id = PaymentMethod.find_by_name("Tarjeta de Crédito").id
    debt_card_method_id = PaymentMethod.find_by_name("Tarjeta de Débito").id
    other_method_id = PaymentMethod.find_by_name("Otro").id

    transactions.each do |transaction|
      new_transaction = PaymentTransaction.new
      if transaction[:payment_method_type] == "0"

        new_transaction.payment_method_id = transaction[:payment_method_id]
        if new_transaction.payment_method_id == credit_card_method_id
          new_transaction.payment_method_type_id = transaction[:payment_method_type_id]
          new_transaction.installments = transaction[:installments]
        elsif new_transaction.payment_method_id == check_method_id
          new_transaction.bank_id = transaction[:bank_id]
        end

        if new_transaction.payment_method_id != cash_method_id
          if PaymentMethodSetting.where(:company_setting_id => current_user.company.company_setting.id, :payment_method_id => new_transaction.payment_method_id).count > 0
            method_setting = PaymentMethodSetting.where(:company_setting_id => current_user.company.company_setting.id, :payment_method_id => new_transaction.payment_method_id).first
            if method_setting.active
              if method_setting.number_required
                if !transaction[:method_number].blank?
                  new_transaction.number = transaction[:method_number]
                else
                  @errors << "El número de comprobante no puede estar vacío."
                end
              else

              end
            else
              @errors << "El tipo de pago no está activo."
            end
          end
        end

      else
        new_transaction.company_payment_method_id = transaction[:payment_method_id]
        company_method = CompanyPaymentMethod.find(transaction[:payment_method_id])
        if !company_method.nil?
          if company_method.number_required
            if !transaction[:method_number].blank?
              new_transaction.number = transaction[:method_number]
            else
              @errors << "El número de comprobante no puede estar vacío."
            end
          end
        else
          @errors << "No existe el medio de pago."
        end
      end

      new_transaction.amount = transaction[:amount].to_f
      new_transaction.payment = payment

      if @errors.length == 0
        unless new_transaction.save
          @errors << new_transaction.errors
        end
      end

    end

    non_discount_total = 0.0
    discount_total = 0.0

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
          mock_booking.list_price = new_booking[:price].to_f
          mock_booking.discount = new_booking[:discount].to_f
          mock_booking.price = (mock_booking.list_price * (100 - mock_booking.discount) / 100).round(1)

          non_discount_total += mock_booking.list_price
          discount_total += mock_booking.price

          mock_booking.client_id = payment.client_id
          @mockBookings << mock_booking

          new_receipt.mock_bookings << mock_booking

        elsif item[:item_type] == "past_booking"
          past_booking = item
          booking = Booking.find(past_booking[:id])
          #booking.list_price = past_booking[:]
          booking.discount = past_booking[:discount]
          booking.price = (past_booking[:list_price].to_f*(100-booking.discount)/100).round(1)

          non_discount_total += past_booking[:list_price]
          discount_total += booking.price

          @bookings << booking
          new_receipt.bookings << booking
        else
          product = item
          payment_product = PaymentProduct.new
          payment_product.product_id = product[:id]
          payment_product.list_price = product[:price]
          payment_product.discount = product[:discount]
          payment_product.price = (payment_product.list_price * (100 - payment_product.discount) / 100).round(1)
          payment_product.quantity = product[:quantity]

          non_discount_total += payment_product.list_price * payment_product.quantity
          discount_total += payment_product.price * payment_product.quantity

          seller = product[:seller].split("_")
          payment_product.seller_id = seller[0]
          payment_product.seller_type = seller[1]

          new_receipt.payment_products << payment_product

          #Update location_product stock

          location_product = LocationProduct.where(:location_id => payment.location_id, :product_id => payment_product.product_id).first
          if location_product.nil?
            @errors << "No existe el producto para el local."
          else
            location_product.stock = location_product.stock - payment_product.quantity
            location_product.save
          end

          @paymentProducts << payment_product
        end
      end

      new_receipt.payment = payment
      
      unless new_receipt.save
        @errors << new_receipt.errors
      end

    end

    payment.amount = discount_total
    payment.discount = ((1 - (discount_total/non_discount_total)) * 100).round(1)

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

    if @json_response[0] == "ok" && @errors.length == 0
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

    payment.cashier_id = params[:cashier_id]

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
    transactions = JSON.parse(params[:transactions], symbolize_names: true)

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

      location_product = LocationProduct.where(:location_id => payment.location_id, :product_id => payment_product.product_id).first
      if location_product.nil?
        @errors << "No existe el producto para el local."
      else
        location_product.stock = location_product.stock + payment_product.quantity
        location_product.save
      end

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

    payment.payment_transactions.each do |transaction|
      transaction.delete
    end


    #
    # Deletes and disassociations done.
    # Now reconstruct
    #

    check_method_id = PaymentMethod.find_by_name("Cheque").id
    cash_method_id = PaymentMethod.find_by_name("Efectivo").id
    credit_card_method_id = PaymentMethod.find_by_name("Tarjeta de Crédito").id
    debt_card_method_id = PaymentMethod.find_by_name("Tarjeta de Débito").id
    other_method_id = PaymentMethod.find_by_name("Otro").id

    transactions.each do |transaction|
      new_transaction = PaymentTransaction.new
      if transaction[:payment_method_type] == "0"

        new_transaction.payment_method_id = transaction[:payment_method_id]
        if new_transaction.payment_method_id == credit_card_method_id
          new_transaction.payment_method_type_id = transaction[:payment_method_type_id]
          new_transaction.installments = transaction[:installments]
        elsif new_transaction.payment_method_id == check_method_id
          new_transaction.bank_id = transaction[:bank_id]
        end

        if new_transaction.payment_method_id != cash_method_id
          if PaymentMethodSetting.where(:company_setting_id => current_user.company.company_setting.id, :payment_method_id => new_transaction.payment_method_id).count > 0
            method_setting = PaymentMethodSetting.where(:company_setting_id => current_user.company.company_setting.id, :payment_method_id => new_transaction.payment_method_id).first
            if method_setting.active
              if method_setting.number_required
                if !transaction[:method_number].blank?
                  new_transaction.number = transaction[:method_number]
                else
                  @errors << "El número de comprobante no puede estar vacío."
                end
              else

              end
            else
              @errors << "El tipo de pago no está activo."
            end
          end
        end

      else
        new_transaction.company_payment_method_id = transaction[:payment_method_id]
        company_method = CompanyPaymentMethod.find(transaction[:payment_method_id])
        if !company_method.nil?
          if company_method.number_required
            if !transaction[:method_number].blank?
              new_transaction.number = transaction[:method_number]
            else
              @errors << "El número de comprobante no puede estar vacío."
            end
          end
        else
          @errors << "No existe el medio de pago."
        end
      end

      new_transaction.amount = transaction[:amount].to_f
      new_transaction.payment = payment

      if @errors.length == 0
        unless new_transaction.save
          @errors << new_transaction.errors
        end
      end

    end

    non_discount_total = 0.0
    discount_total = 0.0

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
          mock_booking.price = (mock_booking.list_price * (100 - mock_booking.discount) / 100).round(1)

          non_discount_total += mock_booking.list_price
          discount_total += mock_booking.price

          mock_booking.client_id = payment.client_id
          @mockBookings << mock_booking

          new_receipt.mock_bookings << mock_booking

        elsif item[:item_type] == "past_booking"
          past_booking = item
          booking = Booking.find(past_booking[:id])
          #booking.list_price = past_booking[:]
          booking.discount = past_booking[:discount]
          booking.price = (past_booking[:list_price].to_f*(100-booking.discount)/100).round(1)

          non_discount_total += past_booking[:list_price]
          discount_total += booking.price

          booking.client_id = client.id

          @bookings << booking
          booking.payment = payment
          new_receipt.bookings << booking
        else
          product = item
          payment_product = PaymentProduct.new
          payment_product.product_id = product[:id]

          payment_product.list_price = product[:price]
          payment_product.discount = product[:discount]
          payment_product.price = (payment_product.list_price * (100 - payment_product.discount) / 100).round(1)
          payment_product.quantity = product[:quantity]

          non_discount_total += payment_product.list_price * payment_product.quantity
          discount_total +=payment_product.price * payment_product.quantity

          seller = product[:seller].split("_")
          payment_product.seller_id = seller[0]
          payment_product.seller_type = seller[1]

          location_product = LocationProduct.where(:location_id => payment.location_id, :product_id => payment_product.product_id).first
          if location_product.nil?
            @errors << "No existe el producto para el local."
          else
            location_product.stock = location_product.stock - payment_product.quantity
            location_product.save
          end

          new_receipt.payment_products << payment_product

          @paymentProducts << payment_product
        end
      end

      new_receipt.payment = payment
      
      unless new_receipt.save
        @errors << new_receipt.errors
      end

    end

    payment.amount = discount_total
    payment.discount = ((1 - (discount_total/non_discount_total)) * 100).round(1)

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
        location_product = LocationProduct.where(:location_id => @payment.location_id, :product_id => payment_product.product_id).first
        if location_product.nil?
          errors << "No existe el producto para el local."
        else
          location_product.stock = location_product.stock + payment_product.quantity
          location_product.save
        end
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

    @payment.payment_transactions.each do |transaction|
      if transaction.delete
      else
        errors << transaction.errors
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

  ###############
  # Commissions #
  ###############

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
      @service_categories = ServiceCategory.where(id: Service.where(id: ServiceStaff.where( service_provider_id: @service_providers.pluck(:id)).pluck(:service_id)).pluck(:service_category_id))
      @service_commissions = ServiceCommission.where(service_provider_id: @service_providers.pluck(:id))
    end

    respond_to do |format|
      format.html
    end

  end

  #Returns a list of providers and service_commissions for given service
  def service_commissions

    service = Service.find(params[:service_id])

    providers = []

    if current_user.role_id == Role.find_by_name("Administrador Local").id
      providers = service.service_providers.where(location_id: current_user.locations.pluck(:id))
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
      service_commissions << {id: service_commission.id, service_id: service.id, service_name: service.name, provider_id: provider.id, provider_name: provider.public_name, amount: service_commission.amount, is_percent: service_commission.is_percent}
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
      service_commissions << {id: service_commission.id, service_id: service.id, service_name: service.name, provider_id: provider.id, provider_name: provider.public_name, amount: service_commission.amount, is_percent: service_commission.is_percent}
    end

    render :json => service_commissions

  end

  def set_default_commission

    @errors = []
    @json_response = [] 
    service = Service.find(params[:service_id])

    service.comission_value = params[:comission_value]

    if !params[:comission_option].blank?
      service.comission_option = params[:comission_option]
    else
      #Someone messed with the js/html
      @errors << "El tipo de comisión es incorrecto."
      @json_response << "error"
      @json_response << @errors
      render :json => @json_response
      return
    end

    if service.save
      #Change commission for all providers
      providers = []

      if current_user.role_id == Role.find_by_name("Administrador Local").id
        providers = service.service_providers.where(location_id: current_user.locations.pluck(:id))
      else
        providers = service.service_providers
      end

      providers.each do |provider|
        service_commission = ServiceCommission.new
        if ServiceCommission.where(:service_id => service.id, :service_provider_id => provider.id).count > 0
          service_commission = ServiceCommission.where(:service_id => service.id, :service_provider_id => provider.id).first
        end
        service_commission.service_id = service.id
        service_commission.service_provider_id = provider.id
        service_commission.amount = service.comission_value
        if service.comission_option == 0
          service_commission.is_percent = true
        else
          service_commission.is_percent = false
        end
        unless service_commission.save
          @errors << service_commission.errors
        end
      end

    else
      @errors << service.errors
    end

    if @errors.length == 0
      @json_response << "ok"
      @json_response << service
    else
      @json_response << "error"
      @json_response << @errors
    end

    render :json => @json_response

  end

  def set_provider_default_commissions

    @errors = []
    @json_response = [] 

    provider = ServiceProvider.find(params[:provider_id])

    provider.services.each do |service|
      service_commission = ServiceCommission.new
      if ServiceCommission.where(:service_id => service.id, :service_provider_id => provider.id).count > 0
        service_commission = ServiceCommission.where(:service_id => service.id, :service_provider_id => provider.id).first
      end

      service_commission.service_id = service.id
      service_commission.service_provider_id = provider.id
      service_commission.amount = params[:amount]
      service_commission.is_percent = params[:is_percent]

      unless service_commission.save
        @errors << service_commission.errors
      end
    end

    if @errors.length == 0
      @json_response << "ok"
      @json_response << provider
    else
      @json_response << "error"
      @json_response << @errors
    end

    render :json => @json_response

  end

  def set_commissions

    service_commissions = JSON.parse(params[:service_commissions], symbolize_names: true)

    @errors = []
    @json_response = []

    service_commissions.each do |servCom|
      service_commission = ServiceCommission.find(servCom[:id])
      service_commission.amount = servCom[:amount]
      service_commission.is_percent = servCom[:is_percent]
      unless service_commission.save
        @errors << service_commission.errors
      end
    end

    if @errors.length == 0
      @json_response << "ok"
    else
      @json_response << "error"
      @json_response << @errors
    end

    render :json => @json_response

  end

  def get_product_for_payment_or_sale
    
    location_product = LocationProduct.where(:location_id => params[:location_id], :product_id => params[:product_id]).first
    product_hash = {
      location_product_id: location_product.id,
      product_id: location_product.product.id,
      product_name: location_product.product.name,
      stock: location_product.stock,
      price: location_product.product.price,
      internal_price: location_product.product.internal_price
    }
    render :json => product_hash

  end

  def save_internal_sale
    @json_response = []
    @errors = []

    if params[:location_id].blank? || params[:cashier_id].blank? || params[:service_provider_id].blank? || params[:product_id].blank? || params[:date].blank? || params[:price].blank? || params[:discount].blank? || params[:quantity].blank?
      @json_response[0] = "error"
      @json_response[1] = "No se ingresaron correctamente los datos."
      render :json => @json_response
      return
    end

    internal_sale = InternalSale.new
    is_edit = false
    old_location_product = nil
    old_quantity = 0

    if !params[:internal_sale_id].blank? && params[:internal_sale_id] != "-1"
      internal_sale = InternalSale.find(params[:internal_sale_id])
      if ! internal_sale.nil?
        is_edit = true
        old_location_product = LocationProduct.where(:location_id => internal_sale.location_id, :product_id => internal_sale.product_id).first
        old_quantity = internal_sale.quantity
      else
        @errors << "No existe la venta ingresada."
      end
    end

    if Location.where(id: params[:location_id]).count > 0
      internal_sale.location_id = params[:location_id]
    else
      @errors << "No existe el local ingresado."
    end

    if Cashier.where(id: params[:cashier_id]).count > 0
      internal_sale.cashier_id = params[:cashier_id]
    else
      @errors << "No existe el cajero ingresado."
    end

    if ServiceProvider.where(id: params[:service_provider_id]).count > 0
      internal_sale.service_provider_id = params[:service_provider_id]
    else
      @errors << "No existe el prestador ingresado."
    end

    if Product.where(id: params[:product_id]).count > 0
      internal_sale.product_id = params[:product_id]
    else
      @errors << "No existe el producto ingresado."
    end

    location_product = LocationProduct.where(:location_id => params[:location_id], :product_id => params[:product_id]).first

    if !location_product.nil?
      if location_product.stock < params[:quantity].to_i
        @errors << "No hay suficiente stock del producto."
      end
    else
      @errors << "No existe el producto para el local ingresado."
    end

    internal_sale.list_price = params[:price].to_f
    internal_sale.discount = params[:discount].to_f
    internal_sale.quantity = params[:quantity].to_i
    internal_sale.price = (internal_sale.list_price*(100 - internal_sale.discount)/100).round(1)
    internal_sale.date = params[:date].to_date

    if @errors.length == 0
      if internal_sale.save

        if is_edit && !old_location_product.nil?
          old_location_product.stock += old_quantity
          old_location_product.save
        end

        location_product.stock = location_product.stock - internal_sale.quantity
        if location_product.save
          @json_response[0] = "ok"
          @json_response[1] = internal_sale
        else
          @json_response[0] = "error"
          @errors << location_product.errors
          @json_response[1] = @errors
        end
      else
        @json_response[0] = "error"
        @errors << internal_sale.errors
      end
    end

    render :json => @json_response

  end

  def delete_internal_sale

    json_response = []
    errors = []
    internal_sale = InternalSale.find(params[:internal_sale_id])
    location_product = LocationProduct.where(:location_id => internal_sale.location_id, :product_id => internal_sale.product_id).first

    if internal_sale.nil? || location_product.nil?
      json_response[0] = "error"
      errors << "Datos ingresados incorrectamente."
      json_response[1] << errors
      render :json => json_response
      return
    end

    quantity = internal_sale.quantity

    if internal_sale.delete
      location_product.stock += quantity
      location_product.save
      json_response[0] = "ok"
    else
      json_response[0] = "error"
      errors << "No se pudo eliminar la venta."
      json_response[1] << errors
    end

    render :json => json_response

  end

  def get_internal_sale
    internal_sale = InternalSale.find(params[:internal_sale_id])
    render :json => internal_sale
  end

  ##############
  # Petty Cash #
  ##############

  def petty_cash
    petty_cash = nil
    @json_response = []
    if PettyCash.where(location_id: params[:location_id]).count > 0
      petty_cash = PettyCash.find_by_location_id(params[:location_id])
    else
      petty_cash = PettyCash.create(:location_id => params[:location_id], :cash => 0, :open => true)
    end
    if !petty_cash.nil?
      @json_response << "ok"
      @json_response << petty_cash
    else
      @json_response << "error"
      @json_response << "Ocurrió un error al cargar la caja."
    end
    render :json => @json_response
  end

  def petty_transactions
    petty_cash = PettyCash.find(params[:petty_cash_id])
    start_date = DateTime.now.to_date.to_datetime
    if !params[:start_date].blank?
      start_date = params[:start_date].to_datetime
    end
    end_date = DateTime.now.to_date.to_datetime + 1.days
    if !params[:end_date]
      end_date = params[:end_date].to_datetime + 1.days
    end
    petty_transactions = PettyTransaction.where(:petty_cash_id => petty_cash.id).where('? <= date and date <= ?', start_date, end_date).order('date asc')
    @petty_transactions = []
    petty_transactions.each do |petty_transaction|
      arr_datetime = petty_transaction.date.to_s.split(" ")
      str_time = arr_datetime[1]
      arr_date = arr_datetime[0].split("-")
      str_date = arr_date[2] + "/" + arr_date[1] + "/" + arr_date[0]
      str_date = str_date + " " + str_time

      receipt_number = "No aplicable"
      if !petty_transaction.is_income
        receipt_number = petty_transaction.receipt_number
      end

      @petty_transactions << {
        id: petty_transaction.id,
        date: str_date,
        amount: petty_transaction.amount,
        is_income: petty_transaction.is_income,
        transactioner: petty_transaction.get_transactioner_details,
        notes: petty_transaction.notes,
        open: petty_transaction.open,
        receipt_number: receipt_number
      }
    end
    render :json => @petty_transactions
  end

  def petty_transaction
    petty_transaction = PettyTransaction.find(params[:petty_transaction_id])
    render :json => petty_transaction
  end

  def add_petty_transaction
    @json_response = []

    if params[:transactioner].blank?
      @json_response << "error"
      @json_response << "El autor de la transacción es inválido."
      render :json => @json_response
      return
    end

    transactioner = params[:transactioner].split("_")
    transactioner_id = transactioner[0].to_i
    transactioner_type = transactioner[1].to_i

    if transactioner_type == 0
      if ServiceProvider.where(:id => transactioner_id).count == 0
        @json_response << "error"
        @json_response << "El autor de la transacción es inválido."
        render :json => @json_response
        return
      end
    elsif transactioner_type == 1
      if User.where(:id => transactioner_id).count == 0
        @json_response << "error"
        @json_response << "El autor de la transacción es inválido."
        render :json => @json_response
        return
      end
    elsif transactioner_type == 2
      if Cashier.where(:id => transactioner_id).count == 0
        @json_response << "error"
        @json_response << "El autor de la transacción es inválido."
        render :json => @json_response
        return
      end
    else
        @json_response << "error"
        @json_response << "El autor de la transacción es inválido."
        render :json => @json_response
        return
    end

    if PettyCash.where(:id => params[:petty_cash_id]).count == 0
      @json_response << "error"
      @json_response << "El código de caja es incorrecto."
      render :json => @json_response
      return
    end

    if params[:notes].blank?
      @json_response << "error"
      @json_response << "No se puede guardar una transacción sin comentarios."
      render :json => @json_response
      return
    end

    petty_cash = PettyCash.find(params[:petty_cash_id])

    petty_transaction = PettyTransaction.new

    if !params[:petty_transaction_id].blank? && params[:petty_transaction_id] != 0 && params[:petty_transaction_id] != "0"
      petty_transaction = PettyTransaction.find(params[:petty_transaction_id])
      if !petty_transaction.open
        @json_response << "error"
        @json_response << "No se puede editar una transferencia cerrada."
        render :json => @json_response
        return
      end
    end
    petty_transaction.transactioner_id = transactioner[0]
    petty_transaction.transactioner_type = transactioner[1]
    petty_transaction.amount = params[:amount].to_f
    petty_transaction.date = DateTime.now
    petty_transaction.petty_cash_id = petty_cash.id
    petty_transaction.is_income = params[:is_income]
    petty_transaction.notes = params[:notes]
    if !petty_transaction.is_income
      petty_transaction.receipt_number = params[:receipt_number]
    else
      petty_transaction.receipt_number = "No aplicable"
    end

    if petty_transaction.save
      
      if petty_cash.save_with_cash
        @json_response << "ok"
        @json_response << petty_transaction
      else
        @json_response << "error"
        @json_response << "No se puede hacer un retiro mayor que la cantidad de dinero en caja."
      end
    else
      @json_response << "error"
      @json_response << petty_transaction.errors
    end

    render :json => @json_response

  end

  def open_close_petty_cash

    @json_response = []

    transactioner = params[:transactioner].split("_")
    transactioner_id = transactioner[0].to_i
    transactioner_type = transactioner[1].to_i

    if transactioner_type == 0
      if ServiceProvider.where(:id => transactioner_id).count == 0
        @json_response << "error"
        @json_response << "El autor de la transacción es inválido."
        render :json => @json_response
        return
      end
    elsif transactioner_type == 1
      if User.where(:id => transactioner_id).count == 0
        @json_response << "error"
        @json_response << "El autor de la transacción es inválido."
        render :json => @json_response
        return
      end
    elsif transactioner_type == 2
      if Cashier.where(:id => transactioner_id).count == 0
        @json_response << "error"
        @json_response << "El autor de la transacción es inválido."
        render :json => @json_response
        return
      end
    else
        @json_response << "error"
        @json_response << "El autor de la transacción es inválido."
        render :json => @json_response
        return
    end

    petty_cash = PettyCash.find(params[:petty_cash_id])

    if params[:option] == "open"
      petty_cash.set_open(params[:new_cash].to_f, transactioner_id, transactioner_type)
    elsif params[:option] == "close"
      petty_cash.set_close(params[:new_cash].to_f, transactioner_id, transactioner_type)
    else
      @json_response << "error"
      @json_response << "La opción ingresada es incorrecta."
      render :json => @json_response
      return
    end

    @json_response << "ok"
    @json_response << petty_cash
    render :json => @json_response

  end

  def delete_petty_transaction
    @json_response = []
    petty_transaction = PettyTransaction.find(params[:petty_transaction_id])
    if petty_transaction.is_income
      if petty_transaction.petty_cash.cash - petty_transaction.amount < 0
        @json_response << "error"
        @json_response << "La caja no puede tener saldo menor que 0."
        render :json => @json_response
        return
      end
    end
    if petty_transaction.delete
      @json_response << "ok"
      @json_response << petty_transaction
      render :json => @json_response
    else
      @json_response << "error"
      @json_response << petty_transaction.errors
      render :json => @json_response
    end
  end

  def set_petty_cash_close_schedule
    @json_response = []
    petty_cash = PettyCash.find(params[:petty_cash_id])
    petty_cash.scheduled_close = params[:scheduled_close]
    petty_cash.scheduled_keep_cash = params[:scheduled_keep_cash]
    petty_cash.scheduled_cash = params[:scheduled_cash]
    if petty_cash.save
      @json_response << "ok"
      @json_response << petty_cash
      render :json => @json_response
    else
      @json_response << "error"
      @json_response << petty_cash.errors
      render :json => @json_response
    end
  end

  ##############
  # Sales Cash #
  ##############

  def sales_cash
    sales_cash = nil
    if SalesCash.where(location_id: params[:location_id]).count > 0
      sales_cash = SalesCash.find_by_location_id(params[:location_id])
    else
      sales_cash = SalesCash.create(:location_id => params[:location_id], :cash => 0, :last_reset_date => DateTime.now)
    end
  end

  #################
  # Sales Reports #
  #################

  def sales_reports

    #Distinguish by role
    #Administrador General can see any report.
    #Administrador local and Recepcionista can see reports for their locations only.
    #Staff can see reports associated to their providers only.

    @locations = []
    @service_providers = []
    @cashiers = []
    @users = []

    if current_user.role_id == Role.find_by_name("Administrador General").id
      @locations = current_user.company.locations
      @service_providers = ServiceProvider.where(location_id: @locations.pluck(:id))
      @cashiers = current_user.company.cashiers
      @users = current_user.company.users
    elsif current_user.role_id == Role.find_by_name("Administrador Local").id || current_user.role_id == Role.find_by_name("Recepcionista").id
      @locations = current_user.locations
      @service_providers = ServiceProvider.where(location_id: @locations.pluck(:id))
      @users = User.where(id: UserLocation.where(location_id: @locations.pluck(:id)).pluck(:user_id))
    elsif current_user.tole_id == Role.find_by_name("Staff") || current_user.role_id == Role.find_by_name("Staff (sin edición)")
      @service_providers = current_user.service_providers
    end

  end

  def service_providers_report

    service_provider_ids = params[:service_provider_ids]
    @service_providers = ServiceProvider.where(id: service_provider_ids)
    @from = DateTime.now
    @to = DateTime.now

    respond_to do |format|
      format.html { render :partial => 'service_providers_report' }
      format.json { render json: @serviceProviders }
    end

  end

  def users_report

  end

  def cashiers_report

  end

  private
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(:amount, :payed, :payment_date, :location_id, :client_id, :notes, booking_ids: [], bookings_attributes: [:id, :discount, :price], payment_products_attributes: [:product_id, :quantity, :discount, :price])
    end
end
