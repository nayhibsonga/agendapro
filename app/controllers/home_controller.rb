class HomeController < ApplicationController
	layout "home"
	
	def index
	end

	def features
	end

	def about_us
	end

	def contact
	end

	def post_contact
		flash[:notice] = "Gracias por contactarnos"

		@contact_info = Hash.new
		@contact_info['firstName'] = params[:inputName]
		@contact_info['lastName'] = params[:inputLastname]
		@contact_info['email'] = params[:inputEmail]
		@contact_info['subject'] = params[:inputSubject]
		@contact_info['message'] = params[:inputMessage]

		HomeMailer.contact_mail(@contact_info).deliver

		render :contact
	end
end
