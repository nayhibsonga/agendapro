class ApplicationController < ActionController::Base

	layout "login" #:layout

	include UrlHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "/403"
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
    devise_parameter_sanitizer.for(:sign_up) << :email
    devise_parameter_sanitizer.for(:sign_up) << :phone
    devise_parameter_sanitizer.for(:sign_up) << :role_id
    devise_parameter_sanitizer.for(:sign_up) << :company_id

    #Agregado para poder editar el perfil de usuario
    devise_parameter_sanitizer.for(:account_update) << :first_name
    devise_parameter_sanitizer.for(:account_update) << :last_name
    devise_parameter_sanitizer.for(:account_update) << :email
    devise_parameter_sanitizer.for(:account_update) << :phone

  end

  def quick_add
    if current_user && (current_user.role_id != Role.find_by_name("Super Admin").id) && current_user.company_id
      @company = Company.find(current_user.company_id)
      if @company.locations.count == 0
        redirect_to(quick_add_path)
      elsif @company.services.count == 0
        redirect_to(quick_add_path(:step => 1))
      elsif @company.service_providers.count == 0
        redirect_to(quick_add_path(:step => 2))
      end
    end
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

  private 

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  # def layout
  #   if is_a?(Devise::SessionsController)
  #     return "login"
  #   elsif is_a?(Devise::RegistrationsController)
  #     return "login"
  #   end
  # end

end
