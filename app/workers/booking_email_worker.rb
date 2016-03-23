class BookingEmailWorker < BaseEmailWorker

  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    booking = Booking.find(sending.sendable_id)

    if booking.send_mail
      recipients = filter_mails(self.get_receipients(booking, "client", sending.method))
      total_sendings += 1
      total_recipients += recipients.size
      BookingMailer.delay.send(sending.method, booking, recipients.join(', '), horachic: self.horachic?(sending.method, booking))
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

    def self.horachic?(method, booking)
      methods = ["new_booking", "cancel_booking", "reminder_booking", "update_booking"]
      return booking.marketplace_origin && methods.include?(method)
    end
end
