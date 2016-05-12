class StatsCompany < ActiveRecord::Base
  belongs_to :company

  def self.update_stats
  	Company.all.each do |company|
  		stats = StatsCompany.find_or_initialize_by(company_id: company.id)
  		stats.company_name = company.name
  		stats.company_start = company.created_at
  		stats.company_payment_status_id = company.payment_status_id
  		stats.company_sales_user_id = company.sales_user_id
  		stats.web_bookings = 0.0
  		if Booking.where(location_id: Location.where(company_id: company.id)).count > 0
  			stats.last_booking = Booking.where(location_id: Location.where(company_id: company.id)).last.created_at
  			stats.web_bookings = Booking.where(location_id: Location.where(company_id: company.id), web_origin: true).count.to_f / Booking.where(location_id: Location.where(company_id: company.id)).count.to_f
  		end
  		stats.week_bookings = Booking.where(location_id: Location.where(company_id: company.id), created_at: 7.days.ago..Time.now).count
  		stats.past_week_bookings = Booking.where(location_id: Location.where(company_id: company.id), created_at: 14.days.ago..7.days.ago).count
			stats.last_payment = "#{company.last_payment_detail[0]}"
			stats.last_payment_method = "#{company.last_payment_detail[1]} #{company.last_payment_detail[2]}"
  		stats.save
  	end
  end
end
