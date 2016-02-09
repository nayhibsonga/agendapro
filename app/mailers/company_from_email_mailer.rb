class CompanyFromEmailMailer < Base::CustomMailer

	def confirm_email (email, current_user)
		company = Company.find(current_user.company_id)

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
			:tags => ['companysetting'],
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
