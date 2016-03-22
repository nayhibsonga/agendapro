class UserMailer < Base::CustomMailer
  layout "mailers/green"

  def welcome_email(user, recipient)
    # layout variables
    @title = "Bienvenido a AgendaPro"
    attacht_logo()

    # view variables
    @user = user

    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  #################### Legacy ####################
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

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end

end
