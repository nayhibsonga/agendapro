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
		@contact_info[:firstName] = params[:inputName]
		@contact_info[:lastName] = params[:inputLastname]
		@contact_info[:email] = params[:inputEmail]
		@contact_info[:subject] = params[:inputSubject]
		@contact_info[:message] = params[:inputMessage]

		ContactEmailWorker.perform(@contact_info, false)

		if params[:source] == "search"
			redirect_to root_path, notice: "¡Gracias por contactarnos! Te responderemos a la brevedad."
		elsif params[:source] == "features"
			redirect_to features_path, notice: "¡Gracias por contactarnos! Te responderemos a la brevedad."
		else
			redirect_to contact_path, notice: "¡Gracias por contactarnos! Te responderemos a la brevedad."
		end
	end

	def mobile_contact
		if params.has_key?('inputName') and params.has_key?('inputEmail')
			@contact_info = Hash.new
			@contact_info[:firstName] = params[:inputName]
			@contact_info[:lastName] = nil
			@contact_info[:email] = params[:inputEmail]
			@contact_info[:subject] = "Nueva Empresa (Sitio Móvil)"
			@contact_info[:message] = params[:inputMessage]
			@contact_info[:phone] = params[:inputPhone]

			ContactEmailWorker.perform(@contact_info, true)

			redirect_to root_path, notice: "¡Gracias por contactarnos! Te responderemos a la brevedad."
		end
	end
end
