class DashboardController < ApplicationController

  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"

	def index
		# @lastBookings = Booking.all.order("id desc").limit(5).reverse

		if current_user.company.company_setting.online_cancelation_policy.nil?
			ocp = OnlineCancelationPolicy.new
			ocp.company_setting_id = current_user.company.company_setting.id
			ocp.save
			current_user.company.company_setting.online_cancelation_policy = ocp
			current_user.company.company_setting.save
		end

		@due_payment = true if Company.find(current_user.company_id).payment_status == PaymentStatus.find_by_name("Emitido") unless current_user.role_id == Role.find_by_name("Super Admin").id
		@service_providers = ServiceProvider.where(location_id: Location.where(company_id: current_user.company_id).accessible_by(current_ability))
		@lastBookings = Booking.where(service_provider_id: @service_providers).where('start >= ?', Time.now).order(updated_at: :desc).limit(50)
		@todayBookings = Booking.where(service_provider_id: @service_providers).where("DATE(start) = DATE(?)", Time.now).order(:start)
		@monthBookings = Booking.where(service_provider_id: @service_providers).where("created_at BETWEEN ? AND ?", Time.now.beginning_of_month, Time.now.end_of_month)
		@statusArray = []
		Status.all.each do |status|
			@statusArray.push([status.name,@monthBookings.where(:status_id => status.id).count])
		end

		if mobile_request?
      @company = current_user.company
    end
	end

end
