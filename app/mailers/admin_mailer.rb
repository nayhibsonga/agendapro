class AdminMailer < ActionMailer::Base
	require 'mandrill'
	require 'base64'

	include ActionView::Helpers::NumberHelper

	def notify_promo_creation(service)
		template_name = 'Admin Promo Notification'
		template_content = []

		locations = ''
		service_promo = ServicePromo.find(service.active_service_promo_id)
		location_ids = service_promo.promos.pluck(:location_id).uniq

		location_ids.each do |l_id|
			location = Location.find(l_id)
			locations = locations + location.name + '<br />'
		end

		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'Promociones AgendaPro',
			:subject => 'Nueva promoción en ' + service.company.name,
			:to => [{
								:email => 'nrossi@agendapro.cl',
								:name => 'Nicolás Rossi',
								:type => 'to'

					},
					{
								:email => 'iegomez@agendapro.cl',
								:name => 'Ignacio Gómez',
								:type => 'to'

					},
					{
								:email => 'mariapaz@agendapro.cl',
								:name => 'María Paz Del Pedregal',
								:type => 'to'

					}
					],
			:headers => { 'Reply-To' => 'nrossi@agendapro.cl' },
			:global_merge_vars => [
				{
					:name => 'COMPANY',
					:content => service.company.name
				},
				{
					:name => 'SERVICE',
					:content => service.name
				},
				{
					:name => 'LOCATIONS',
					:content => locations
				}
			],
			:merge_vars => [],
			:tags => [],
			:images => [
				{
					:type => 'image/png',
					:name => 'LOGO',
					:content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
				}
			]
		}

		send_mail(template_name, template_content, message)

	end

	private
		def send_mail(template_name, template_content, message)
			mandrill = Mandrill::API.new Agendapro::Application.config.api_key
			# => Metadata
			async = false
			send_at = DateTime.now

			result = mandrill.messages.send_template template_name, template_content, message, async, send_at

			rescue Mandrill::Error => e
				puts "A mandrill error occurred: #{e.class} - #{e.message}"
				raise
		end

end