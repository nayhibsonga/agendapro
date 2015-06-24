class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"
  load_and_authorize_resource

  respond_to :html, :json

  def index
    @payments = Payment.all
    respond_with(@payments)
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
    @payment.update(payment_params)
    respond_with(@payment)
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
        @past_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @booking.location_id, client_id: @client.id, payment_id: nil).where("start < ?", @booking.start.beginning_of_day).order(start: :desc).limit(100).pluck(:id)
      else
        @payment = Payment.new
        @elegible_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @booking.location_id, client_id: @client.id, payment_id: nil).where("start > ?", @booking.start.beginning_of_day).order(:start).limit(10)
        @past_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: @booking.location_id, client_id: @client.id, payment_id: nil).where("start < ?", @booking.start.beginning_of_day).order(start: :desc).limit(100).pluck(:id)
      end
    elsif !params[:client_id].blank? && !params[:location_id].blank?
      @client = Client.find(params[:client_id])
      @payment = Payment.new
      @elegible_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: params[:location_id], client_id: @client.id, payment_id: nil).where("start > ?", (Time.now - eval(ENV["TIME_ZONE_OFFSET"])).beginning_of_day).order(:start).limit(10)
      @past_bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado")).where(location_id: params[:location_id], client_id: @client.id, payment_id: nil).where("start < ?", (Time.now - eval(ENV["TIME_ZONE_OFFSET"])).beginning_of_day).order(start: :desc).limit(100).pluck(:id)
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

  def past_bookings
    weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
    @full_past_bookings = Booking.where(id: params[:booking_ids]).order(start: :desc)
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
      params.require(:payment).permit(:amount, :receipt_type_id, :receipt_number, :payment_method_id, :payment_method_number, :payment_method_type_id, :installments, :payed, :payment_date, :bank_id, :company_payment_method_id, booking_ids: [])
    end
end
