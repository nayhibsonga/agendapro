class NotificationEmailWorker < BaseEmailWorker

  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    notification = NotificationEmail.find(sending.sendable_id)
    recipients = filter_mails([notification.email])
    case notification.receptor_type
    when 0 # Company summary
      today_bookings = Booking.where(location_id: Location.where(company: notification.company).actives).where("DATE(start) = DATE(?)", Time.now).where.not(status: Status.find_by(name: 'Cancelado')).where('is_session = false or (is_session = true and is_session_booked = true)').order(:start)
      summary_bookings = Booking.where(location_id: Location.where(company: notification.company, active: true), updated_at: (Time.now - 1.day)..Time.now).where('is_session = false or (is_session = true and is_session_booked = true)').order(:start)
      name = notification.company.name
      if today_bookings.length > 0 || summary_bookings.length > 0
        total_sendings += 1
        total_recipients += recipients.size
        NotificationMailer.delay.send(method, recipients.join(', '), today_bookings, summary_bookings, name)
      end
    when 1 # Location summary
      Location.where(id: notification.locations.actives).each do |location|
        today_bookings = Booking.where(location: location).where("DATE(start) = DATE(?)", Time.now).where.not(status: Status.find_by(name: 'Cancelado')).where('is_session = false or (is_session = true and is_session_booked = true)').order(:start)
        summary_bookings = Booking.where(location: location, updated_at: (Time.now - 1.day)..Time.now).where('is_session = false or (is_session = true and is_session_booked = true)').order(:start)
        name = location.name
        if today_bookings.length > 0 || summary_bookings.length > 0
          total_sendings += 1
          total_recipients += recipients.size
          NotificationMailer.delay.send(method, recipients.join(', '), today_bookings, summary_bookings, name)
        end
      end
    when 2 # Service Provider summary
      ServiceProvider.where(id: notification.service_providers.actives).each do |provider|
        today_bookings = Booking.where(service_provider: provider).where("DATE(start) = DATE(?)", Time.now).where.not(status: Status.find_by(name: 'Cancelado')).where('is_session = false or (is_session = true and is_session_booked = true)').order(:start)
        summary_bookings = Booking.where(service_provider: provider, updated_at: (Time.now - 1.day)..Time.now).where('is_session = false or (is_session = true and is_session_booked = true)').order(:start)
        name = provider.public_name
        if today_bookings.length > 0 || summary_bookings.length > 0
          total_sendings += 1
          total_recipients += recipients.size
          NotificationMailer.delay.send(method, recipients.join(', '), today_bookings, summary_bookings, name)
        end
      end
    end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: @total_sendings, total_recipients: @total_recipients)
  end
end
