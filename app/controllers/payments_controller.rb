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
      if @booking.payment
        @payment = @booking.payment
        @elegible_bookings = @payment.bookings
        @past_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @booking.location_id, client_id: @client.id, payment_id: nil).where.not(id: @payment.bookings.pluck(:id)).limit(100).pluck(:id)
      else
        @payment = Payment.new
        @elegible_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @booking.location_id, client_id: @client.id, payment_id: nil).where(start: @booking.start.beginning_of_day..@booking.start.end_of_day).order(:start)
        @past_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @booking.location_id, client_id: @client.id, payment_id: nil).where.not(start: @booking.start.beginning_of_day..@booking.start.end_of_day).order(start: :desc).limit(100).pluck(:id)
      end
    elsif !params[:client_id].blank? && !params[:location_id].blank?
      @client = Client.find(params[:client_id])
      @payment = Payment.new
      @elegible_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @booking.location_id, client_id: @client.id, payment_id: nil).where(start: (Time.now - eval(ENV["TIME_ZONE_OFFSET"])).beginning_of_day..(Time.now - eval(ENV["TIME_ZONE_OFFSET"])).end_of_day).order(:start)
        @past_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @booking.location_id, client_id: @client.id, payment_id: nil).where.not(start: (Time.now - eval(ENV["TIME_ZONE_OFFSET"])).beginning_of_day..(Time.now - eval(ENV["TIME_ZONE_OFFSET"])).end_of_day).order(start: :desc).limit(100).pluck(:id)
    else

    end

    @payment_bookings = @payment.id ? @payment.bookings.pluck(:id) : @elegible_bookings.where(payment_id: nil).pluck(:id)
    @bookings = []
    @elegible_bookings.each do |b|
      @bookings.push( { booking: b, booking_checked: @payment_bookings.include?(b.id), booking_service: b.service.name, booking_provider: b.service_provider.public_name, booking_date: weekdays[b.start.wday] + ' ' + b.start.strftime('%d-%m-%Y'), booking_time: b.start.strftime('%R'), booking_price: b.service.price.round(0) } )
    end

    @products = @payment.payment_products

    render :json => {payment: @payment, client: @client, bookings: @bookings, products: @products, past_bookings: @past_bookings }
  end

  def load_payment
    weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
    @payment = Payment.find(params[:payment_id])
    @client = @payment.client
    @elegible_bookings = @payment.bookings
    @past_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @payment.location_id, client_id: @client.id, payment_id: nil).where.not(id: @elegible_bookings.pluck(:id)).limit(100).pluck(:id)

    @payment_bookings = @payment.id ? @payment.bookings.pluck(:id) : @elegible_bookings.where(payment_id: nil).pluck(:id)
    @bookings = []
    @elegible_bookings.each do |b|
      @bookings.push( { booking: b, booking_checked: @payment_bookings.include?(b.id), booking_service: b.service.name, booking_provider: b.service_provider.public_name, booking_date: weekdays[b.start.wday] + ' ' + b.start.strftime('%d-%m-%Y'), booking_time: b.start.strftime('%R'), booking_price: b.service.price.round(0) } )
    end

    @products = @payment.payment_products

    render :json => {payment: @payment, client: @client, bookings: @bookings, products: @products, past_bookings: @past_bookings }
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

  def client_bookings
    weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
    @full_past_bookings = Booking.where(client_id: params[:client_id], location_id: params[:location_id], payment_id: nil).order(start: :desc).limit(100)
    @past_bookings = []
    @full_past_bookings.each do |b|
      @past_bookings.push({ booking: b, booking_checked: true, booking_service: b.service.name, booking_provider: b.service_provider.public_name, booking_date: weekdays[b.start.wday] + ' ' + b.start.strftime('%d-%m-%Y'), booking_time: b.start.strftime('%R'), booking_price: b.service.price.round(0) })
    end
    render :json => { past_bookings: @past_bookings }
  end

  private
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(:amount, :receipt_type_id, :receipt_number, :payment_method_id, :payment_method_number, :payment_method_type_id, :installments, :payed, :payment_date, :bank_id, :company_payment_method_id, :location_id, :client_id, :notes, booking_ids: [], bookings_attributes: [:id, :discount, :price], payment_products_attributes: [:product_id, :quantity, :discount, :price])
    end
end
