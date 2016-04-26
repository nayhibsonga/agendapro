class SessionsBookingEmailWorker < BaseEmailWorker

  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    session = SessionBooking.find(sending.sendable_id)
    bookings = session.booked_bookings.order(:start)

    recipients = filter_mails([bookings.first.client.email])
    total_sendings += 1
    total_recipients += recipients.size
    SessionsBookingMailer.delay.send(sending.method, bookings.to_a, recipients.join(', '))

    # Providers
    bookings.map { |b| b.service_provider }.uniq.each do |provider|
      recipients = filter_mails(NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: provider), receptor_type: 2).distinct.pluck(:email))
      name = provider.public_name
      recipients.in_groups_of(50).each do |group|
        group.compact!
        total_sendings += 1
        total_recipients += group.size
        SessionsBookingMailer.delay.send(sending.method, bookings.where(service_provider: provider).to_a, group.join(', '), client: false, name: name) if group.size > 0
      end
    end

    # Location
    recipients = filter_mails(NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: bookings.first.location), receptor_type: 1).distinct.pluck(:email))
    name = bookings.first.location.name
    recipients.in_groups_of(50).each do |group|
      group.compact!
      total_sendings += 1
      total_recipients += group.size
      SessionsBookingMailer.delay.send(sending.method, bookings.to_a, group.join(', '), client: false, name: name) if group.size > 0
    end

    # Company
    recipients = filter_mails(NotificationEmail.where(company:  bookings.first.location.company, receptor_type: 0).distinct.pluck(:email))
    name = bookings.first.location.company.name
    recipients.in_groups_of(50).each do |group|
      group.compact!
      total_sendings += 1
      total_recipients += group.size
      SessionsBookingMailer.delay.send(sending.method, bookings.to_a, group.join(', '), client: false, name: name) if group.size > 0
    end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end
end
