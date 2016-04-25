class MailInterceptor
  def self.delivering_email(message)
    if Rails.env != 'production'
      message.subject = "[#{message.to}] #{message.subject}"
      message.to = ENV['EMAIL_FILTER'] || message.to
    end

    if message.to.empty? && message.cc.empty? && message.bcc.empty? && message.smtp_envelope_to.empty?
      message.perform_deliveries = false
      puts "Blocked email"
    end
  end
end
