class ApplicationController < ActionController::Base

	layout :layout

	include UrlHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
    devise_parameter_sanitizer.for(:sign_up) << :email
    devise_parameter_sanitizer.for(:sign_up) << :phone
    devise_parameter_sanitizer.for(:sign_up) << :role_id
  end

  def verify_is_super_admin
    redirect_to(dashboard_path) unless (current_user.role_id == Role.find_by_name("Super Admin").id)
  end

  def verify_is_admin
    redirect_to(dashboard_path) unless (current_user.role_id == Role.find_by_name("Admin").id)
  end

  def verify_is_local_admin
    redirect_to(dashboard_path) unless (current_user.role_id == Role.find_by_name("Administrador Local").id)
  end

  def verify_is_staff
    redirect_to(dashboard_path) unless (current_user.role_id == Role.find_by_name("Staff").id)
  end

  def verify_is_user
    redirect_to(dashboard_path) unless (current_user.role_id == Role.find_by_name("Usuario Registrado").id)
  end

  private

  def layout
    if is_a?(Devise::SessionsController)
      return "login"
    elsif is_a?(Devise::RegistrationsController)
      return "login"
    else
      return "admin"
    end
  end

end
