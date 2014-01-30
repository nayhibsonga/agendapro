class DashboardController < ApplicationController
	
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"

	def index
		@lastBookings = Booking.where(service_provider_id: ServiceProvider.where(company_id: current_user.company_id))
	end
	
end
