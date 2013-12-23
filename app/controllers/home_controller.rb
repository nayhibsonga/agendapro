class HomeController < ApplicationController
	layout "home"
	
	def index
	  if current_user
	    redirect_to :controller=>'dashboard', :action => 'index'
	  end
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
