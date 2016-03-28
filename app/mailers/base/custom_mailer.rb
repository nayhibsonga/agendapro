class Base::CustomMailer < ActionMailer::Base
  require 'mandrill'
  require 'base64'

  # layout "mailers/green", except: :send_mail

  default reply_to: 'contacto@agendapro.cl'

  before_action :default_options

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
    return recipients if Rails.env == 'production'
    ENV['EMAIL_FILTER'] || recipients
  end

  def filter_sender(email=nil)
    email.present? ? email : "AgendaPro <no-reply@agendapro.cl>"
  end

  private
    def default_options
      @title = "AgendaPro"
      @url = "www.agendapro.co"
      headers["X-MC-PreserveRecipients"] = "false"
    end
end
