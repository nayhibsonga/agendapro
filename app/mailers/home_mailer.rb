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
          :name => contact_info['lastName'] + ', ' + contact_info['firstName'],
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
      :tags => ['contact'],
      :images => [
        {
          :type => 'image/png',
          :name => 'AgendaPro.png',
          :content => Base64.encode64(File.read('app/assets/images/logos/logo_mail.png'))
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
