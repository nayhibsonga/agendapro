class ClientMailer < ActionMailer::Base
  require 'mandrill'
  require 'base64'

  def send_client_mail (current_user, clients, subject, message, company_img)
	mandrill = Mandrill::API.new 'HL4ERbuZZO6rrM2nlVjzZg'
	
	# => Template
	template_name = 'clientmail'
	template_content = []

	# => Message
	message = {
		:from_email => current_user.email,
		:from_name => current_user.last_name + ', ' + current_user.first_name,
		:subject => subject,
		:to => clients,
		:global_merge_vars => [
			{
				:name => 'UNSUBSCRIBE',
				:content => "Si desea dejar de recibir email puede dar click <a href='#{unsubscribe_url(:user => Base64.encode64(current_user.email))}'>aquí</a>."
			},
			{
				:name => 'MESSAGE',
				:content => message
			}
		],
		:tags => ['client_mail', 'Client'],
		:images => [
			{
				:type => 'image/png',
				:name => 'AgendaPro.png',
				:content => Base64.encode64(File.read('app/assets/images/logos/logo_mail.png'))
			}
		]
	}

	if company_img.length > 0
		message[:images] << (company_img)
	end

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