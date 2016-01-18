class ClientEmailWorker

  def self.perform(sending)
    content = Email::Content.find(sending.sendable_id)
    content.to.split(', ').each do |recipient|
      ClientMailer.delay.send_campaign(content, recipient.strip.downcase)
    end
    sending.update(status: 'delivered', sent_date: DateTime.now)
  end

end
