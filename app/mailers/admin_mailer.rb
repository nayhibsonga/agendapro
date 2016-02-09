class AdminMailer < Base::CustomMailer

	include ActionView::Helpers::NumberHelper

	def notify_promo_creation(service)
		template_name = 'Admin Promo Notification'
		template_content = []

		locations = ''
		location_ids = []

		if !service.active_service_promo.nil?
			location_ids = location_ids + service.active_service_promo.promos.pluck(:location_id).uniq
		end

		if !service.active_last_minute_promo.nil?
			location_ids = location_ids + service.active_last_minute_promo.locations.pluck(:id)
		end

		location_ids = location_ids.uniq

		location_ids.each do |l_id|
			location = Location.find(l_id)
			locations = locations + location.name + '<br />'
		end

		message = {
			:from_email => 'no-reply@agendapro.cl',
			:from_name => 'Promociones AgendaPro',
			:subject => 'Creación o edición de promoción en ' + service.company.name,
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
				},
				{
					:name => 'DOMAIN',
					:content => service.company.country.domain
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
end
