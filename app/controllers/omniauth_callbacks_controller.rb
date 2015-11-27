class OmniauthCallbacksController < Devise::OmniauthCallbacksController

	def facebook

      if request.env["omniauth.auth"]["info"]["email"].nil? || request.env["omniauth.auth"]["info"]["email"] == ""
        flash[:alert] = "Lo sentimos, tu cuenta de Facebook no tiene un correo electrónico asociado, por lo que no podremos registrarte"
        redirect_to new_user_registration_url
      else
      	@user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)      
       	if @user.persisted?       
        		sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        		set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      	else
        		session["devise.facebook_data"] = request.env["omniauth.auth"]
        		redirect_to new_user_registration_url
      	end
      end
	end

  def facebook_marketplace

      if request.env["omniauth.auth"]["info"]["email"].nil? || request.env["omniauth.auth"]["info"]["email"] == ""
        flash[:alert] = "Lo sentimos, tu cuenta de Facebook no tiene un correo electrónico asociado, por lo que no podremos registrarte"
        redirect_to new_user_registration_url
      else
        @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)      
        if @user.persisted?       
            sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
            set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
        else
            session["devise.facebook_data"] = request.env["omniauth.auth"]
            redirect_to new_user_registration_url
        end
      end
  end

  def google_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end

  def google_oauth2_marketplace
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end
	
end