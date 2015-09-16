class UserMailer < ActionMailer::Base
  require 'mandrill'

  def welcome_email(user)
  	mandrill = Mandrill::API.new Agendapro::Application.config.api_key

    # => Template
    template_name = 'User'
    template_content = []

    @user_name = user.email
    if (!user.last_name.blank? && !user.first_name.blank?)
      @user_name = user.first_name + ' ' + user.last_name
    end

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :to => [
        {
          :email => user.email,
          :name => @user_name,
          :type => 'to'
        }
      ],
      :headers => { 'Reply-To' => "contacto@agendapro.cl" },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => 'www'
        },
        {
          :name => 'EMAIL',
          :content => user.email
        },
        {
          :name => 'PASSWORD',
          :content => user.password
        }
      ],
      :tags => ['user', 'new_user'],
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

  def stock_alarm_email(location_product)
    mandrill = Mandrill::API.new Agendapro::Application.config.api_key

    # => Template
    template_name = 'Stock Alarm'
    template_content = []

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :subject => 'Alerta de stock en ' + location_product.location.name,
      :to => [
        {
          :email => location_product.alarm_email,
          :name => location_product.alarm_email,
          :type => 'to'
        }
      ],
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
          :content => location_product.stock_limit.to_s
        },
        {
          :name => 'STOCK',
          :content => location_product.stock.to_s
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
