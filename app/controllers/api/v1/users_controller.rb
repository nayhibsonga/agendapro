module Api
  module V1
  	class UsersController < V1Controller
  	  skip_before_filter :check_auth_token, only: [:login]

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