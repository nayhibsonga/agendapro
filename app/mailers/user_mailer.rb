class UserMailer < ActionMailer::Base
  require 'mandrill'

  def welcome_email(user)
  	mandrill = Mandrill::API.new 'HL4ERbuZZO6rrM2nlVjzZg'

    # => Template
    template_name = 'User'
    template_content = []

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :to => [
        {
          :email => user.email,
          :name => user.last_name + ', ' + user.first_name,
          :type => 'to'
        }
      ],
      :global_merge_vars => [
        {
          :name => 'UNSUBSCRIBE',
          :content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(user.email))}'>aquí</a>."
        },
        {
          :name => 'FNAME',
          :content => user.first_name
        },
        {
          :name => 'user',
          :content => user.email
        },
        {
          :name => 'URL',
          :content => 'http://www.agendapro.cl/login'
        },
        {
          :name => 'PASSWORD',
          :content => 'contraseña a cambiar'
        }
      ],
      :tags => ['user', 'new_user']
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
