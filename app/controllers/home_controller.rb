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
		flash[:notice] = "Contactado"
		redirect_to contact_path
	end
end
