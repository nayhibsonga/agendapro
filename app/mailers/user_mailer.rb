class UserMailer < Base::CustomMailer

  def welcome_email(user)
    # => Template
    template_name = user.api_token.present? ? 'User - Marketplace' : 'User'
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
