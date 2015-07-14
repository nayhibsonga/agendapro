module Api
  module V1
  	class UsersController < V1Controller
  	  skip_before_filter :check_auth_token, only: [:login]
  	  before_action :check_login_params

  	  def check_login_params
  	  	if !params[:email].present? || !params[:password].present?
			render json: { error: 'Invalid User. Param(s) missing.' }, status: 500
  	  	end
  	  end

      def login
      	@user = User.find_by_email(params[:email])
      	if @user.valid_password?(params[:password])
      		@user.mobile_token = SecureRandom.base64(32)
      		render json: { error: 'Invalid User. User not saved.' }, status: 500 if !@user.save
      	else
      		render json: { error: 'Invalid User' }, status: 403
      	end
      end
  	end
  end
end