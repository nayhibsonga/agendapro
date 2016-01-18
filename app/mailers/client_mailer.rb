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

  def process_campaign(id)
    content = Email::Content.find(id)
    content.to.split(', ').each do |recipient|
      send_campaign(content, recipient.strip.downcase)
    end
  end

  def send_campaign(content, recipient)
    @content = content
    @data = @content.data
    @email = true
    subject = (Rails.env == 'production' ? @content.subject : "#{@content.subject} (#{recipient})")
    mail(
      from: filter_sender("#{@content.company.name.titleize} <#{@content.from}>"),
      to: filter_recipient(recipient),
      subject: subject,
      template_path: Email::Template::TMPL_DIR,
      template_name: "_"+@content.template.name
      )
  end
end
