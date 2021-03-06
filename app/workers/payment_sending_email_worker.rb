class PaymentSendingEmailWorker < BaseEmailWorker

  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    payment_sending = PaymentSending.find(sending.sendable_id)

    targets = payment_sending.emails.split(',').size
    recipients = filter_mails(payment_sending.emails.split(','))
    payment = payment_sending.payment

    recipients.in_groups_of(50).each do |group|
      group.compact!
      total_sendings += 1
      total_recipients += group.size
      PaymentsSystemMailer.delay.send(sending.method, payment, group.join(', ')) if group.size > 0
    end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: @total_sendings, total_recipients: @total_recipients, total_targets: targets)
  end
end
