class MailInterceptor
  def self.delivering_email(message)
    if Rails.env != 'production'
      message.subject = "[#{message.to}] #{message.subject}"
      message.to = ENV['EMAIL_FILTER'] || message.to
      message.bcc = ""
    end

    if message.to.empty? && message.cc.nil? && message.bcc.nil? && message.smtp_envelope_to.nil?
      message.perform_deliveries = false
      puts "Blocked email"
    end
  end
end
