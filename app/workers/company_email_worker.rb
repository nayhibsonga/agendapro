class CompanyEmailWorker < BaseEmailWorker
  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    company = Company.find(sending.sendable_id)
    admins = company.users.where(role: Role.find_by_name('Administrador General')).pluck(:email)

    recipients = filter_mails(admins)
    recipients.in_groups_of(1000).each do |group|
      group.compact!
      total_sendings += 1
      total_recipients += group.size
      CompanyMailer.delay.send(sending.method, company, group.join(', '))
    end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end
end
