class BookingEmailWorker < BaseEmailWorker

  def self.perform(sending)
    booking = Booking.find(sending.sendable_id)

    unless booking.marketplace_origin
      self.perform_agendapro(booking, sending)
    else
      self.perform_horachic(booking, sending)
    end
  end

  private
    def self.get_receipients(booking, recipient_type = "", method = "")
      # Filter recipient
      recipients = case recipient_type
      when "client" then booking.client
      when "provider" then NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: booking.service_provider), receptor_type: 2).select(:email).distinct
      when "location" then NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: booking.location), receptor_type: 1).select(:email).distinct
      when "company" then NotificationEmail.where(company: booking.location.company, receptor_type: 0).select(:email).distinct
      else NotificationEmail.none
      end

      # Filter method
      recipients = case method
      when "new_booking" then booking.web_origin ? recipients.where(new_web: true) : recipients.where(new: true)
      when "cancel_booking" then booking.web_origin ? recipients.where(canceled_web: true) : recipients.where(canceled: true)
      when "reminder_booking" then recipients.where(summary: false)
      when "confirm_booking" then booking.web_origin ? recipients.where(confirmed_web: true) : recipients.where(confirmed: true)
      when "update_booking" then booking.web_origin ? recipients.where(modified_web: true) : recipients.where(modified: true)
      else NotificationEmail.none
      end unless recipient_type == "client"

      # Get emails
      unless recipient_type == "client" && method == "confirm_booking"
        recipient_type == "client" ? [recipients.email] : recipients.pluck(:email)
      else
        []
      end
    end

    def self.perform_agendapro(booking, sending)
      total_sendings = 0
      total_recipients = 0

      if booking.send_mail
        recipients = filter_mails(self.get_receipients(booking, "client", sending.method))
        total_sendings += 1
        total_recipients += recipients.size
        BookingMailer.delay.send(sending.method, booking, recipients.join(', '))
      end

      recipients = filter_mails(self.get_receipients(booking, "provider", sending.method))
      name = booking.service_provider.public_name
      recipients.in_groups_of(1000).each do |group|
        group.compact!
        total_sendings += 1
        total_recipients += group.size
        BookingMailer.delay.send(sending.method, booking, group.join(', '), client: false, name: name)
      end

      recipients = filter_mails(self.get_receipients(booking, "location", sending.method))
      name = booking.location.name
      recipients.in_groups_of(1000).each do |group|
        group.compact!
        total_sendings += 1
        total_recipients += group.size
        BookingMailer.delay.send(sending.method, booking, group.join(', '), client: false, name: name)
      end

      recipients = filter_mails(self.get_receipients(booking, "company", sending.method))
      name = booking.location.company.name
      recipients.in_groups_of(1000).each do |group|
        group.compact!
        total_sendings += 1
        total_recipients += group.size
        BookingMailer.delay.send(sending.method, booking, group.join(', '), client: false, name: name)
      end

      sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
    end

    def self.perform_horachic(booking, sending)
      total_sendings = 0
      total_recipients = 0

      case sending.method
      when "new_booking"
        BookingMailer.delay.book_service_mail(booking)
      when "cancel_booking"
        BookingMailer.delay.cancel_booking_legacy(booking)
      when "reminder_booking"
        BookingMailer.delay.book_reminder_mail(booking)
      when "update_booking"
        BookingMailer.delay.update_booking_legacy(booking)
      else
        self.perform(booking, sending)
        return
      end
      sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients, detail: ["legacy marketplace"])
    end
end
