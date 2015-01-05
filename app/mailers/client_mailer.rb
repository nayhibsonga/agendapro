class ClientMailer < ActionMailer::Base
  require 'mandrill'
  require 'base64'

  def send_client_mail (current_user, clients, subject, message, company_img, attachment, from)
	mandrill = Mandrill::API.new Agendapro::Application.config.api_key
	
	# => Template
	template_name = 'clientmail'
	template_content = []

	# => Message
	message = {
		:from_email => from,
		:from_name => current_user.company.name,
		:subject => subject,
		:to => clients,
		:global_merge_vars => [
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
					:name => 'company.jpg',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			],
		:attachments => []
	}

	# => Logo empresa
	if Company.find(current_user.company_id).logo_url
		company_logo = {
			:type => 'image/' +  File.extname(Company.find(current_user.company_id).logo_url),
			:name => 'company.jpg',
			:content => Base64.encode64(File.read('public' + Company.find(current_user.company_id).logo_url.to_s))
		}
		message[:images] = [company_logo]
	end

	if attachment.length > 0
		message[:attachments] << (attachment)
	end

	# => Metadata
	async = true
	send_at = DateTime.now

	# => Send mail
	result = mandrill.messages.send_template template_name, template_content, message, async, send_at

	rescue Mandrill::Error => e
		puts "A mandrill error occurred: #{e.class} - #{e.message}"
		raise
  end
end