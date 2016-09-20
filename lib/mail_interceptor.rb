class MailInterceptor
  def self.delivering_email(message)
    unless Rails.env == 'production'
      message.subject = "[#{message.to}] #{message.subject}"
      message.to = ENV['EMAIL_FILTER'] || message.to
      message.bcc = ""
    end

    if message.to.nil? && message.cc.nil? && message.bcc.nil? && message.smtp_envelope_to.nil?
      message.perform_deliveries = false
      puts "Blocked email #{message.subject}"
    end
  end
end
