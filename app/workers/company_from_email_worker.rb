class CompanyFromEmailWorker < BaseEmailWorker

  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    email_from = CompanyFromEmail.find(sending.sendable_id)

    recipients = filter_mails([email_from.email])
    total_sendings += 1
    total_recipients += recipients.size
    CompanyFromEmailMailer.delay.send(sending.method, email_from, recipients.join(', ')) if recipients.size > 0

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end

end
