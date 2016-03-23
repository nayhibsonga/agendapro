class ReceiptEmailWorker < BaseEmailWorker

  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    receipt = self.receipt(sending)

    company = self.company(receipt, sending.sendable_type)
    admins = company.users.where(role: Role.find_by_name('Administrador General')).pluck(:email)
    admins << "cuentas@agendapro.cl"

    recipients = filter_mails(admins)
    recipients.in_groups_of(1000).each do |group|
      group.compact!
      total_sendings += 1
      total_recipients += group.size
      CompanyMailer.delay.send(sending.method, company, group.join(', '))
    end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end

  private
    def self.receipt(sending)
      case sending.sendable_type
      when "PayUNotification"
        PayUNotification.find(sending.sendable_id)
      when "PuntoPagosConfirmation"
        PuntoPagosConfirmation.find(sending.sendable_id)
      end
    end

    def self.company(receipt, sendable_type)
      company_id = case sendable_type
      when "PayUNotification"
        if BillingLog.find_by_trx_id(receipt.reference_sale)
          billing_log = BillingLog.find_by_trx_id(receipt.reference_sale).company_id
        elsif PlanLog.find_by_trx_id(receipt.reference_sale)
          plan_log = PlanLog.find_by_trx_id(receipt.reference_sale).company_id
      when "PuntoPagosConfirmation"
        if BillingLog.find_by_trx_id(receipt.trx_id)
          billing_log = BillingLog.find_by_trx_id(receipt.trx_id).company_id
        elsif PlanLog.find_by_trx_id(receipt.trx_id)
          plan_log = PlanLog.find_by_trx_id(receipt.trx_id).company_id
      end
      company = Company.find(company_id)
    end
end
