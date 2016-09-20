class BillingRecord < ActiveRecord::Base
	belongs_to :company
	belongs_to :transaction_type

	validates :company, presence: true

	after_save :update_stats_company

	def update_stats_company
		company = self.company
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

		bl = BillingLog.where(:company_id => company.id).where(:trx_id => PuntoPagosConfirmation.where(:response => "00").pluck(:trx_id)).order('created_at desc').first
		rec = BillingRecord.where(:company_id => company.id).order('date desc').first
		if !bl.nil? && !rec.nil?
			if bl.created_at <= rec.date
				stats.last_payment = rec.date
				stats.last_payment_method = "Manual - " + (rec.transaction_type ? rec.transaction_type.name : "No definido")
			else
				stats.last_payment = bl.created_at
				stats.last_payment_method = "Automático"
			end
		elsif bl.nil? && !rec.nil?
			stats.last_payment = rec.date
			stats.last_payment_method = "Manual - " + (rec.transaction_type ? rec.transaction_type.name : "No definido")
		elsif !bl.nil? && rec.nil?
			stats.last_payment = bl.created_at
			stats.last_payment_method = "Automático"
		end
		stats.save
	end
end
