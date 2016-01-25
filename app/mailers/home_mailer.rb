class HomeMailer < Base::CustomMailer

  def contact_mail (contact_info)
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
        },
        {
          :name => 'CLIENTEMAIL',
          :content => contact_info['email']
        },
        {
          :name => 'SUBJECT',
          :content => contact_info['subject']
        },
        {
          :name => 'URL',
          :content => 'www'
        }
      ],
      :tags => ['contact'],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
        }
      ]
    }

    # => Send mail
    send_mail(template_name, template_content, message)
  end

  def mobile_contact (contact_info)
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
        },
        {
          :name => 'URL',
          :content => 'www'
        }
      ],
      :tags => ['contact'],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
        }
      ]
    }

    # => Send mail
    send_mail(template_name, template_content, message)
  end
end
