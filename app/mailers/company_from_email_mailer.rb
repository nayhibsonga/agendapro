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
					:content => confirm_email_url(:confirmation_code => email.confirmation_code)
				},
				{
					:name => 'COMPANYNAME',
					:content => Company.find(current_user.company_id).name
				},
				{
					:name => 'URL',
					:content => Company.find(current_user.company_id).web_address
				}
			],
			:tags => ['companysetting'],
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
