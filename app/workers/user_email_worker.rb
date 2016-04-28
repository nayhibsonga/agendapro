class UserEmailWorker < BaseEmailWorker

  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    user = User.find(sending.sendable_id)

    recipients = filter_mails([user.email])
    total_sendings += 1
    total_recipients += recipients.size

    UserMailer.delay.send(sending.method, user, recipients.join(', '), nil) if recipients.size > 0

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end

end
