class PaymentsSystemMailer < ActionMailer::Base
  require 'mandrill'

  def stock_alarm_email(location_product)
    mandrill = Mandrill::API.new Agendapro::Application.config.api_key

    # => Template
    template_name = 'Stock Alarm'
    template_content = []

    emails = []
    recipients = []

    location_product.stock_emails.each do |stock_email|
      if !emails.include?(stock_email.email)
        emails << stock_email.email
      end
    end

    location_product.location.stock_alarm_setting.stock_setting_emails.each do |stock_email|
      if !emails.include?(stock_email.email)
        emails << stock_email.email
      end
    end

    emails.each do |email|
      recipients << {
        :email => email,
        :name => email,
        :type => 'to'
      }
    end

    stock_limit = location_product.stock_limit
    if stock_limit.nil?
      stock_limit = location_product.location.stock_alarm_setting.default_stock_limit
    end

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :subject => 'Alerta de stock en ' + location_product.location.name,
      :to => recipients,
      :headers => { 'Reply-To' => "contacto@agendapro.cl" },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => 'www'
        },
        {
          :name => 'PRODUCT',
          :content => location_product.product.full_name
        },
        {
          :name => 'LOCATION',
          :content => location_product.location.name
        },
        {
          :name => 'STOCKLIMIT',
          :content => stock_limit.to_s
        },
        {
          :name => 'STOCK',
          :content => location_product.stock.to_s
        },
        {
          :name => 'DOMAIN',
          :content => location_product.location.company.country.domain
        }
      ],
      :tags => [],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
        }
      ]
    }

    # => Metadata
    async = false
    send_at = DateTime.now

    # => Send mail
    result = mandrill.messages.send_template template_name, template_content, message, async, send_at

    rescue Mandrill::Error => e
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      raise
  end

  def stock_reminder_email(location, stocks, emails)
    mandrill = Mandrill::API.new Agendapro::Application.config.api_key

    # => Template
    template_name = 'Stock Reminder'
    template_content = []

    recipients = []

    emails.each do |email|
      recipients << {
        :email => email,
        :name => email,
        :type => 'to'
      }
    end

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :subject => 'Recordatorio de stock para ' + location.name,
      :to => recipients,
      :headers => { 'Reply-To' => "contacto@agendapro.cl" },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => 'www'
        },
        {
          :name => 'LOCATION',
          :content => location.name
        },
        {
          :name => 'STOCKS',
          :content => stocks
        },
        {
          :name => 'DOMAIN',
          :content => location.company.country.domain
        }

      ],
      :tags => [],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
        }
      ]
    }

    # => Metadata
    async = false
    send_at = DateTime.now

    # => Send mail
    result = mandrill.messages.send_template template_name, template_content, message, async, send_at

    rescue Mandrill::Error => e
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      raise
  end

  def receipts_email(payment, emails, data)

    mandrill = Mandrill::API.new Agendapro::Application.config.api_key

    # => Template
    template_name = 'Payment Receipts'
    template_content = []

    company = payment.location.company

    recipients = []

    emails.each do |email|
      recipients << {
        :email => email,
        :name => email,
        :type => 'to'
      }
    end

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => company.name,
      :subject => 'Comprobantes de pago',
      :to => recipients,
      :headers => { 'Reply-To' => payment.location.email },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => 'www'
        },
        {
          :name => 'RECEIPTS',
          :content => data
        },
        {
          :name => 'COMPANY',
          :content => company.name
        },
        {
          :name => 'LOCATION',
          :content => payment.location.name
        },
        {
          :name => 'DOMAIN',
          :content => company.country.domain
        }
      ],
      :tags => [],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
        }
      ]
    }

    # => Metadata
    async = false
    send_at = DateTime.now

    # => Send mail
    result = mandrill.messages.send_template template_name, template_content, message, async, send_at

    rescue Mandrill::Error => e
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      raise

  end

end