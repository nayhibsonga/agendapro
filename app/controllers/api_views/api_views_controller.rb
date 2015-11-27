class ApiViews::ApiViewsController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_filter :check_auth_token

	def check_auth_token
		if !request.headers['X-Auth-Token'].present?
			@api_user = User.new
		else
			@api_user = User.find_by_api_token(request.headers['X-Auth-Token'])
			if !@api_user.present?
				@api_user = User.new
			end
		end
	end
end