class PayedBookingEmailWorker < BaseEmailWorker
  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    payed_booking = PayedBooking.find(sending.sendable_id)
    client = payed_booking.bookings.first.client
    owner = User.find_by_company_id(payed_booking.bookings.first.location.company.id)

    recipients = filter_mails([client.email])
    total_sendings += 1
    total_recipients += recipients.size
    PayedBookingMailer.delay.send(sending.method, payed_booking, recipients.join(', '), client: true)

    recipients = filter_mails([owner.email])
    total_sendings += 1
    total_recipients += recipients.size
    PayedBookingMailer.delay.send(sending.method, payed_booking, recipients.join(', '), client: false, company: true)

    recipients = filter_mails(["contacto@agendapro.cl"])
    total_sendings += 1
    total_recipients += recipients.size
    PayedBookingMailer.delay.send(sending.method, payed_booking, recipients.join(', '), client: false, agendapro: true)

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end
end