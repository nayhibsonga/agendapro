class ClientsController < ApplicationController
	
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"

	def index
		@company = Company.where(id: current_user.company_id)
    	@locations = Location.where(company_id: @company)
    	@service_providers = ServiceProvider.where(location_id: @locations)
    	@bookings = Booking.where(service_provider_id: @service_providers)
		@clients = @bookings.pluck(:first_name, :last_name, :email, :phone).uniq
	end

end
