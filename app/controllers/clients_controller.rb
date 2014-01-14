class ClientsController < ApplicationController
	
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"

	def index
	end

end
