class DashboardController < ApplicationController

  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"

  def index
    host = request.host_with_port
    @url = host[host.index(request.domain)..host.length]

    unless current_user.role_id == Role.find_by_name("Super Admin").id || current_user.role_id == Role.find_by_name("Ventas").id
      if current_user.company.company_setting.online_cancelation_policy.nil?
        ocp = OnlineCancelationPolicy.new
        ocp.company_setting_id = current_user.company.company_setting.id
        ocp.save
        current_user.company.company_setting.online_cancelation_policy = ocp
        current_user.company.company_setting.save
      end

      # Datos estaticos
      @due_payment = true if Company.find(current_user.company_id).payment_status == PaymentStatus.find_by_name("Emitido") unless current_user.role_id == Role.find_by_name("Super Admin").id

      @locations = Location.where(company_id: current_user.company_id).accessible_by(current_ability).order(:order, :name)
      @service_providers = ServiceProvider.where(location_id: @locations).order(:order, :public_name)

      @monthBookings = Booking.where(service_provider_id: @service_providers).where("created_at BETWEEN ? AND ?", Time.now.beginning_of_day - 7.days - eval(ENV["TIME_ZONE_OFFSET"]), Time.now).where('is_session = false or (is_session = true and is_session_booked = true)')
      @statusArray = []
      Status.all.each do |status|
        @statusArray.push([status.name,@monthBookings.where(:status_id => status.id).count])
      end

      @lastBookings = Booking.where(service_provider_id: @service_providers).where('start >= ?', Time.now - eval(ENV["TIME_ZONE_OFFSET"])).where('is_session = false or (is_session = true and is_session_booked = true)').order(updated_at: :desc).limit(50)

      @services = Service.where(:company_id => current_user.company_id).order(:order, :name)
      @potential_session_bookings = SessionBooking.where('client_id is not null').where(service_id: @services).order('updated_at desc').limit(20)
      @session_bookings = []
      @potential_session_bookings.each do |session_booking|
        if session_booking.sessions_amount && session_booking.sessions_taken && session_booking.sessions_amount > session_booking.sessions_taken
          @session_bookings << session_booking
        else
          active_count = session_booking.bookings.where('start > ?', DateTime.now - eval(ENV["TIME_ZONE_OFFSET"])).count
          if active_count > 0
            @session_bookings << session_booking
          end
        end
      end

      # Datos variables
      @payedBookings = @monthBookings.where(payed: true)
      @payedAmount = 0
      @payedBookings.each do |booking|
        @payedAmount += booking.price
      end
      @onlineBookings = @monthBookings.where(web_origin: true)
      @todayBookings = Booking.where(service_provider_id: ServiceProvider.filter_location(params[:location]).filter_provider(params[:provider])).where.not(status_id: Status.find_by_name("Cancelado")).where("DATE(start) = DATE(?)", Time.now - eval(ENV["TIME_ZONE_OFFSET"])).where('is_session = false or (is_session = true and is_session_booked = true)').accessible_by(current_ability).order(:start)

      if mobile_request?
        @company = current_user.company
      end
    end
  end

  def free_plan_landing

  end

end
