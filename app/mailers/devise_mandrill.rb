class DeviseMandrill < Devise::Mailer
  require 'mandrill'

  def reset_password_instructions(record, token, opts={})
  	require 'base64'

  	mandrill = Mandrill::API.new Agendapro::Application.config.api_key

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
      :headers => { 'Reply-To' => "contacto@agendapro.cl" },
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
          :name => 'AgendaPro.png',
          :content => Base64.encode64(File.read('app/assets/images/logos/logo_mail.png'))
        }
      ]
    }

    # => Metadata
    async = false
    send_at = DateTime.now

    # => Send mail
    result = mandrill.messages.send_template template_name, template_content, message, async, send_at

    # Se comentó para no mandar 2 veces el mail.
    # Igual queda pendiente de revisión exhaustiva por falta de información.

    # super

  rescue Mandrill::Error => e
    puts "A mandrill error occurred: #{e.class} - #{e.message}"
    raise
  end

end