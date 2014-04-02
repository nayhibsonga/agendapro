class ClientsController < ApplicationController
	
	before_action :authenticate_user!
	before_action :quick_add
	layout "admin"

	def index
		@company = Company.where(id: current_user.company_id)
		@locations = Location.where(company_id: @company).accessible_by(current_ability)
		@service_providers = ServiceProvider.where(location_id: @locations)
		@bookings = Booking.where(service_provider_id: @service_providers)
		@clients = @bookings.pluck(:first_name, :last_name, :email, :phone).uniq
	end

	def suggestion
		@company = Company.where(id: current_user.company_id)
		@locations = Location.where(company_id: @company)
		@service_providers = ServiceProvider.where(location_id: @locations)
		@bookings = Booking.where(service_provider_id: @service_providers).where('email ~* ?', params[:term])
		@clients = @bookings.pluck(:first_name, :last_name, :email, :phone).uniq

		@clients_arr = Array.new
		@clients.each do |client|
			label = client[2] + ' - ' + client[1] + ', ' + client[0]
			@clients_arr.push({:label => label, :value => client})
		end

		render :json => @clients_arr
	end

	def send_mail
		clients = Array.new
		params[:to].split(',').each do |client_mail|
			client_info = {
				:email => client_mail,
				:type => 'bcc'
			}
			clients.push(client_info)
		end

		if current_user.company.logo_url
			company_img = {
				:type => 'image/' +  File.extname(current_user.company.logo_url),
				:name => 'company_img.jpg',
				:content => Base64.encode64(File.read('public' + current_user.company.logo_url.to_s))
			}
		else
			company_img = {}
		end

		ClientMailer.send_client_mail(current_user, clients, params[:subject], params[:message], company_img)

		redirect_to '/clients', notice: 'Enviando email.'
	end
end
