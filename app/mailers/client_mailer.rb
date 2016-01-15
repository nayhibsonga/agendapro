class ClientMailer < Base::CustomMailer
  helper ClientsHelper

  def send_client_mail (current_user, clients, subject, content, attachment, from)
    company = Company.find(current_user.company_id)

    # => Template
    template_name = 'clientmail'
    template_content = []

    # => Message
    message = {
      :from_email => from,
      :from_name => current_user.company.name,
      :subject => subject,
      :to => clients,
      :global_merge_vars => [
        {
          :name => 'MESSAGE',
          :content => content
        },
        {
          :name => 'SIGNATURE',
          :content => company.company_setting.signature
        },
        {
          :name => 'COMPANYNAME',
          :content => company.name
        },
        {
          :name => 'URL',
          :content => company.web_address
        },
        {
          :name => 'DOMAIN',
          :content => company.country.domain
        }
      ],
      :tags => ['client_mail', 'Client'],
      :images => [
          {
            :type => 'image/png',
            :name => 'LOGO',
            :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
          }
        ],
      :attachments => []
    }

    # => Logo empresa
    if !company.logo.email.url.include? "logo_vacio"
      company_logo = {
        :type => 'image/png',
        :name => 'LOGO',
        :content => Base64.encode64(File.read('public' + company.logo.email.url.to_s))
      }
      message[:images] = [company_logo]
    end

    if attachment.length > 0
      message[:attachments] << (attachment)
    end

    # => Send mail
    send_mail(template_name, template_content, message, false)
  end

  def send_campaign(id)
    @content = Email::Content.find(id)
    @data = @content.data
    @email = true;
    mail(
      from: filter_sender(@content.from),
      to: filter_recipient(@content.to),
      subject: @content.subject,
      template_path: Email::Template::TMPL_DIR,
      template_name: "_"+@content.template.name
      )
  end
end
