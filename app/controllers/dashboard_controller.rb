class DashboardController < ApplicationController
	
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"

	def index
		@lastBookings = Booking.all.order("id desc").limit(5).reverse
		@todayBookings = Booking.where("DATE(start) = DATE(?)", Time.now)
		@monthBookings = Booking.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_month, Time.now.end_of_month)
		@statusArray = []
		Status.all.each do |status|
			@statusArray.push([status.name,@monthBookings.where(:status_id => status.id).count]) 
		end
	end
	
end
