class BookingEmailWorker < BaseEmailWorker

  def self.perform(sending)
    booking = Booking.find(sending.sendable_id)
    total_sendings = 0
    total_recipients = 0

    if booking.send_mail
      recipients = filter_mails([booking.client.email])
      total_sendings += 1
      total_recipients += recipients.size
      BookingMailer.delay.send(sending.method, booking)
    end

    # providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: booking.service_provider), receptor_type: 2).select(:email).distinct
    # if booking.web_origin
    #   providers_emails = providers_emails.where(new_web: true)
    # else
    #   providers_emails = providers_emails.where(new: true)
    # end
    # recipients = filter_mails(providers_emails.pluck(:email))
    # recipients.in_groups_of(1000).each do |group|
    #   group.compact!
    #   total_sendings += 1
    #   total_recipients += group.size
    #   BookingMailer.delay.send(sending.method, booking)
    # end

    # location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: booking.location), receptor_type: 1).select(:email).distinct
    # if booking.web_origin
    #   location_emails = location_emails.where(new_web: true)
    # else
    #   location_emails = location_emails.where(new: true)
    # end
    # recipients = filter_mails(location_emails.pluck(:email))
    # recipients.in_groups_of(1000).each do |group|
    #   group.compact!
    #   total_sendings += 1
    #   total_recipients += group.size
    #   BookingMailer.delay.send(sending.method, booking)
    # end

    # company_emails = NotificationEmail.where(company: booking.location.company, receptor_type: 0).select(:email).distinct
    # if booking.web_origin
    #   company_emails = company_emails.where(new_web: true)
    # else
    #   company_emails = company_emails.where(new: true)
    # end
    # recipients = filter_mails(company_emails.pluck(:email))
    # recipients.in_groups_of(1000).each do |group|
    #   group.compact!
    #   total_sendings += 1
    #   total_recipients += group.size
    #   BookingMailer.delay.send(sending.method, booking)
    # end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end

end
