class ClientEmailWorker < BaseEmailWorker

  def self.perform(sending)
    content = Email::Content.find(sending.sendable_id)
    company = content.company
    targets = content.to.split(', ').uniq.size
    @blacklisted = []
    @formatted = []

    recipients = loggable_filter_mails(content.to.split(', ').uniq)
    if company.reached_mailing_limit? && recipients.size > company.mails_left
      sending.update(status: 'canceled', detail: "Reached monthly limit sending #{recipients.size} mails. (#{company.settings.monthly_mails}/#{company.settings.get_mails_capacity})")
    else
      total_sendings = 0
      total_recipients = 0
      recipients.in_groups_of(30).each do |group|
        group.compact!
        total_sendings += 1
        total_recipients += group.size
        ClientMailer.delay(run_at: total_sendings.seconds.from_now).send_campaign(content, group.join(', ')) if group.size > 0
      end

      @blacklisted.each do |email|
        if Client.find_by(email: email, company_id: content.company_id)
          log = ClientEmailLog.find_or_initialize_by(transmission_id: '', campaign_id: sending.id, client_id: Client.find_by(email: email, company_id: content.company_id))
          log.assign_attributes(status: 'Lista de Suprimidos', recipient: email, timestamp: Time.now, subject: content.subject, progress: 0, details: 'Las direcciones de correos que se reportan como que no existen, tienen errores de formato, marcan como no deseado los correos enviados por AgendaPro o fallan varias veces al intentar entregas, se incluyen en la lista de suprimidos y AgendaPro no les enviará más correos.')
          log.save
        end
      end
      @formatted.each do |email|
        if Client.find_by(email: email, company_id: content.company_id)
          log = ClientEmailLog.find_or_initialize_by(transmission_id: '', campaign_id: sending.id, client_id: Client.find_by(email: email, company_id: content.company_id))
          log.assign_attributes(status: 'Error de Formato', recipient: email, timestamp: Time.now, subject: content.subject, progress: 0, details: 'Las direcciones de correos que se reportan como que no existen, tienen errores de formato, marcan como no deseado los correos enviados por AgendaPro o fallan varias veces al intentar entregas, se incluyen en la lista de suprimidos y AgendaPro no les enviará más correos.')
          log.save
        end
      end

      sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients, total_targets: targets)
      company.settings.update(monthly_mails: company.settings.monthly_mails + total_recipients)
    end
  end

  private
    def self.loggable_filter_mails(recipients)
      filtered = []
      recipients.each do |mail|
        if mail.downcase.is_email?
          if EmailBlacklist.find_by_email(mail).nil?
            filtered << mail.downcase
          else
            Rails.logger.info "Email Blacklisted: #{mail}"
            @blacklisted << mail.downcase
          end
        else
          Rails.logger.info "Email Bad Format: #{mail}"
          @formatted << mail.downcase
        end
      end
      filtered
    end

end
