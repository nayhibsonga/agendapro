class CompanyFromEmailMailer < ActionMailer::Base
	require 'mandrill'
	require 'base64'

	def confirm_email (email, current_user)
		mandrill = Mandrill::API.new Agendapro::Application.config.api_key

		# => Template
		template_name = 'companysetting'
		template_content = []

		# => Message
		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'AgendaPro',
			:subject => 'Confirmar email ' + email.email,
			:to => [
				{
					:email => email.email,
					:type => 'to'
				}
			],
			:headers => { 'Reply-To' => 'contacto@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'CONFIRM',
					:content => "<a class='btn btn-agendapro-claro btn-lg' href='#{confirm_email_url(:confirmation_code => email.confirmation_code)}' style='display: inline-block;padding: 10px 16px;margin-bottom: 0;font-size: 18px;font-weight: normal;line-height: 1.33;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;background-image: none;border: 1px solid transparent;border-radius: 6px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;color: #ffffff;background-color: rgba(61,154,150,1);border-color: rgba(55, 133, 129, 1);text-decoration:none;'>Confirmar E-mail</a>"
				}
			],
			:tags => ['booking', 'new_booking'],
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

		rescue Mandrill::Error => e
			puts "A mandrill error occurred: #{e.class} - #{e.message}"
			raise
	end
end
