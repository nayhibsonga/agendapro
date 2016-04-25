class StockEmailWorker < BaseEmailWorker

  def self.perform(sending)
    total_sendings = 0
    total_recipients = 0

    stock = self.stock(sending)

    recipients = filter_mails(self.recipients(stock))
    recipients.in_groups_of(1000).each do |group|
      group.compact!
      total_sendings += 1
      total_recipients += group.size
      StockMailer.delay.send(sending.method, stock, group.join(', '))
    end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: total_sendings, total_recipients: total_recipients)
  end

  private
    def self.stock(sending)
      case sending.sendable_type
      when "LocationProduct"
        LocationProduct.find(sending.sendable_id)
      when "Location"
        Location.find(sending.sendable_id)
      end
    end

    def self.recipients(stock)
      case stock.class.name
      when "LocationProduct"
        ( stock.stock_emails.pluck(:email) + stock.location.stock_alarm_setting.stock_setting_emails.pluck(:email) ).uniq
      when "Location"
        stock.stock_alarm_setting.stock_setting_emails.pluck(:email)
      end
    end
end