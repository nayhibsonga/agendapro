class HomeMailer < ActionMailer::Base
  require 'mandrill'
  #default from: "agendapro@agendapro.cl"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.home_mailer.contact.subject
  #
  def contact_mail (contact_info)
    require 'base64'

    mandrill = Mandrill::API.new Agendapro::Application.config.api_key

    # => Template
    template_name = 'Contact'
    template_content = []

    # => Message
    message = {
      :subject => contact_info['subject'],
      :from_email => 'contacto@agendapro.cl',
      :from_name => 'Contacto AgendaPro',
      :to => [
        {
          :email => contact_info['email'],
          :name => contact_info['firstName'] + ' ' + contact_info['lastName'],
          :type => 'to'
        },
        {
          :email => 'contacto@agendapro.cl',
          :type => 'to'
        }
      ],
      :headers => { 'Reply-To' => "contacto@agendapro.cl" },
      :global_merge_vars => [
        {
          :name => 'LNAME',
          :content => contact_info['lastName']
        },
        {
          :name => 'FNAME',
          :content => contact_info['firstName']
        },
        {
          :name => 'MESSAGE',
          :content => contact_info['message']
        }
      ],
      :merge_vars => [
        {
          :rcpt => 'contacto@agendapro.cl',
          :vars => [
            {
              :name => 'CLIENTEMAIL',
              :content => contact_info['email']
            }
          ]
        }
      ],
      :tags => ['contact'],
      :images => [
        {
          :type => 'image/png',
          :name => 'agendapro.png',
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

  def mobile_contact (contact_info)
    require 'base64'

    mandrill = Mandrill::API.new Agendapro::Application.config.api_key

    # => Template
    template_name = 'mobile_contact'
    template_content = []

    # => Message
    message = {
      :subject => 'Nueva Empresa (Sitio Móvil)',
      :from_email => contact_info['email'],
      :from_name => contact_info['name'],
      :to => [
        {
          :email => 'contacto@agendapro.cl',
          :type => 'to'
        }
      ],
      :headers => { 'Reply-To' => contact_info['email'] },
      :global_merge_vars => [
        {
          :name => 'NAME',
          :content => contact_info['name']
        },
        {
          :name => 'PHONE',
          :content => contact_info['phone']
        },
        {
          :name => 'EMAIL',
          :content => contact_info['email']
        },
        {
          :name => 'MESSAGE',
          :content => contact_info['message']
        }
      ],
      :tags => ['contact'],
      :images => [
        {
          :type => 'image/png',
          :name => 'agendapro.png',
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
