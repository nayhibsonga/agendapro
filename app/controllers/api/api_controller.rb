class Api::ApiController < ApplicationController
	before_filter :check_auth_token
	skip_before_action :verify_authenticity_token

	def check_auth_token
		if !request.headers['X-Auth-Token'].present?
			return render json: {error: 'Not authenticated. Token not present.'}, status: 403
		else
			@mobile_user = User.find_by_mobile_token(request.headers['X-Auth-Token'])
			if !@mobile_user.present?
				return render json: {error: 'Not authenticated. Invalid Mobile Token'}, status: 403
			end
		end
	end
end