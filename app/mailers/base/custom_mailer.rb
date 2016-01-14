class Base::CustomMailer < ActionMailer::Base
  require 'mandrill'
  require 'base64'

  def send_mail(template_name, template_content, message, async=true)

    mandrill = Mandrill::API.new Agendapro::Application.config.api_key
      # => Metadata
      send_at = DateTime.now

      result = mandrill.messages.send_template(template_name, template_content, message, async, send_at)

    rescue Mandrill::Error => e
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      raise
    return result
  end

  def filter_recipient(recipients)
    ENV['EMAIL_FILTER'] || recipients
  end

  def filter_sender(email)
    email.present ? email : "AgendaPro <no-reply@agendapro.cl>"
  end
end
