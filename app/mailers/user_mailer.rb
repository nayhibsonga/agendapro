class UserMailer < ActionMailer::Base
  require 'mandrill'

  def welcome_email(user)
  	mandrill = Mandrill::API.new Agendapro::Application.config.api_key

    # => Template
    template_name = 'User'
    template_content = []

    @user_fname = user.email
    @user_name = user.email
    if (!user.last_name.blank? && !user.first_name.blank?)
      @user_name = user.first_name + ' ' + user.last_name
      @user_fname = user.first_name
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
        # {
        #   :name => 'UNSUBSCRIBE',
        #   :content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(user.email))}'>aquí</a>."
        # },
        {
          :name => 'FNAME',
          :content => @user_fname
        },
        {
          :name => 'user',
          :content => user.email
        },
        {
          :name => 'URL',
          :content => 'http://www.agendapro.cl'
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
end
