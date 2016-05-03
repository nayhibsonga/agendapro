class ClientEmailWorker < BaseEmailWorker

  def self.perform(sending)
    content = Email::Content.find(sending.sendable_id)
    company = content.company
    recipients = filter_mails(content.to.split(', ').uniq)
    if company.reached_mailing_limit? && recipients.size > company.mails_left
      sending.update(status: 'canceled', detail: "Reached monthly limit sending #{recipients.size} mails. (#{company.settings.monthly_mails}/#{company.settings.get_mails_capacity})")
    else
      total_sendings = 0
      total_recipients = 0
      recipients.in_groups_of(500).each do |group|
        group.compact!
        total_sendings += 1
        total_recipients += group.size
        ClientMailer.delay(run_at: total_sendings.seconds.from_now).send_campaign(content, group.join(', ')) if group.size > 0
      end
      sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
      company.settings.update(monthly_mails: company.settings.monthly_mails + total_recipients)
    end
  end

end
