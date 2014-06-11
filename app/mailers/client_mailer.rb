class ClientMailer < ActionMailer::Base
  require 'mandrill'
  require 'base64'

  def send_client_mail (current_user, clients, subject, message, company_img, attachment)
	mandrill = Mandrill::API.new Agendapro::Application.config.api_key
	
	# => Template
	template_name = 'clientmail'
	template_content = []

	# => Message
	message = {
		:from_email => current_user.email,
		:from_name => current_user.company.name,
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
			},
			{
				:name => 'SIGNATURE',
				:content => Company.find(current_user.company_id).company_setting.signature
			},
			{
				:name => 'COMPANYNAME',
				:content => Company.find(current_user.company_id).name
			}
		],
		:tags => ['client_mail', 'Client'],
		:images => [
				{
					:type => 'image/png',
					:name => 'company_img.jpg',
					:content => Base64.encode64(File.read('app/assets/ico/Iso_Pro_Color.png'))
				}
			],
		:attachments => []
	}

	# => Logo empresa
	if Company.find(current_user.company_id).logo_url
		company_logo = {
			:type => 'image/' +  File.extname(Company.find(current_user.company_id).logo_url),
			:name => 'company_img.jpg',
			:content => Base64.encode64(File.read('public' + Company.find(current_user.company_id).logo_url.to_s))
		}
		message[:images] = [company_logo]
	end

	# if company_img.length > 0
	# 	message[:images] << (company_img)
	# end

	if attachment.length > 0
		message[:attachments] << (attachment)
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