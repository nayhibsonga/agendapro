class PaymentsSystemMailer < Base::CustomMailer
  def receipts (payment, recipient)
    @company = payment.location.company

    # layout variables
    @title = "Comprobantes de pago"
    @url = @company.web_url

    # view variables
    @payment = payment

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  #################### Legacy ####################
  def receipts_email(payment, emails, data)
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

    # => Send mail
    send_mail(template_name, template_content, message)
  end

end
