class ServiceEmailWorker < BaseEmailWorker
  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    service = Service.find(sending.sendable_id)

    recipients = filter_mails(['nrossi@agendapro.cl', 'iegomez@agendapro.cl', 'mariapaz@agendapro.cl'])
    total_sendings += 1
    total_recipients += recipients.size
    AdminMailer.delay.send(sending.method, service, recipients.join(', ')) if recipients.size > 0

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end
end
