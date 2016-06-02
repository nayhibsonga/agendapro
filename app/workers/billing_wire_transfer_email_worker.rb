class BillingWireTransferEmailWorker < BaseEmailWorker
  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    transfer = BillingWireTransfer.find(sending.sendable_id)

    targets = self.get_receipients(transfer, sending.method).size
    recipients = filter_mails(self.get_receipients(transfer, sending.method))
    recipients.in_groups_of(50).each do |group|
      group.compact!
      total_sendings += 1
      total_recipients += group.size
      BillingWireTransferMailer.delay.send(sending.method, transfer, group.join(', ')) if group.size > 0
    end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients, total_targets: targets)
  end

  private
    def self.get_receipients(transfer, method = "")
      # Filter recipient
      recipients = case method
      when "transfer" then ["cuentas@agendapro.cl"]
      when "receipt_transfer" then transfer.company.users.where(role: Role.find_by_name('Administrador General')).pluck(:email)
      else BillingWireTransfer.none
      end
    end
end
