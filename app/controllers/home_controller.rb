class HomeController < ApplicationController
	layout "home"
	
	def index
	end

	def features
	end

	def about_us
	end

	def tutorials
	end

	def contact
	end

	def post_contact
		@contact_info = Hash.new
		@contact_info['firstName'] = params[:inputName]
		@contact_info['lastName'] = params[:inputLastname]
		@contact_info['email'] = params[:inputEmail]
		@contact_info['subject'] = params[:inputSubject]
		@contact_info['message'] = params[:inputMessage]

		HomeMailer.contact_mail(@contact_info)

		if params[:source] == "search"
			redirect_to root_path, notice: "¡Gracias por contactarnos! Te responderemos a la brevedad."
		else
			redirect_to contact_path, notice: "¡Gracias por contactarnos! Te responderemos a la brevedad."
		end
	end
end
