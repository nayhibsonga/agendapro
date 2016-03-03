class UserMailer < Base::CustomMailer
  layout "mailers/green_footer"

  def welcome_email(user)
    @user = user
    name = @user.full_name.present? ? @user.full_name : @user.email
    subject = "Bienvenido a AgendaPro"
    recipient = '#{name.titleize} <#{@user.email}>'

    mail(
      from: filter_sender("AgendaPro <no-reply@agendapro.cl>"),
      to: filter_recipient(recipient),
      subject: subject,
      template_path: "mailers"
      )
  end

  # legacy method
  def welcome_email_legacy(user)
    # => Template
    template_name = 'User - Marketplace'
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
        },
        {
          :name => 'NAME',
          :content => @user_name
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

    # => Send mail
    send_mail(template_name, template_content, message)
  end

end
