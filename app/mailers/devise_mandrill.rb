class DeviseMandrill < Devise::Mailer
  require 'mandrill'

  def reset_password_instructions(record, token, opts={})
  	require 'base64'

  	mandrill = Mandrill::API.new 'HL4ERbuZZO6rrM2nlVjzZg'

    # => Template
    template_name = 'Password'
    template_content = []

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :to => [
        {
          :email => record.email,
          :type => 'to'
        }
      ],
      :global_merge_vars => [
        {
          :name => 'EMAIL',
          :content => record.email
        },
        {
          :name => 'RESET_PASSWORD',
          :content => "<a href='#{edit_user_password_url(:reset_password_token => record.reset_password_token)}'>Cambiar mi contraseña</a>"
        }
      ],
      :tags => ['devise', 'password'],
      :images => [
        {
          :type => 'image/png',
          :name => 'logo.png',
          :content => Base64.encode64(File.read('app/assets/images/home/Logo.png'))
        }
      ]
    }

    # => Metadata
    async = false
    send_at = DateTime.now

    # => Send mail
    result = mandrill.messages.send_template template_name, template_content, message, async, send_at

    super

  rescue Mandrill::Error => e
    puts "A mandrill error occurred: #{e.class} - #{e.message}"
    raise
  end

end