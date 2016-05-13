class SessionBooking < ActiveRecord::Base
	has_many :bookings, dependent: :destroy
	has_many :booked_bookings, -> { where is_session_booked: true, user_session_confirmed: true}, class_name: "Booking"
	has_many :unbooked_bookings, -> { where is_session_booked: false}, class_name: "Booking"
	has_many :unvalidated_bookings, -> { where is_session_booked: true, user_session_confirmed: false}, class_name: "Booking"
  has_many :sendings, class_name: 'Email::Sending', as: :sendable
	belongs_to :service
	belongs_to :user
	belongs_to :client
	belongs_to :treatment_promo

	after_save :count_bookings

  WORKER = 'SessionsBookingEmailWorker'

	def send_sessions_booking_mail
		bookings = self.booked_bookings.order(:start)
	    timezone = CustomTimezone.from_booking(bookings[0])
	    if bookings.order(:start).first.start > Time.now + timezone.offset
	      self.sendings.build(method: 'sessions_booking').save
	    end
	end

	def count_bookings
		taken = self.bookings.where(is_session_booked: true).where.not(status_id: Status.find_by_name("Cancelado").id).count
		self.update_column(:sessions_taken, taken)
	end

end
