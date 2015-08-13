class ApplicationController < ActionController::Base

	layout "home" #:layout

	include UrlHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Mobu::DetectMobile

  before_filter :permitted_params

  before_filter :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "/403"
  end

  protected

  def set_locale
    if params[:locale].blank?
      if Country.find_by(locale: I18n.locale.to_s)
        I18n.locale = I18n.locale
      elsif current_user && current_user.company_id && current_user.company_id > 0
        I18n.locale = Company.find(current_user.company_id).country.locale
      else
        requested_location = request_location
        if requested_location == 'CL'
          I18n.locale = :es_CL
        elsif requested_location == 'CO'
          I18n.locale = :es_CO
        else
          I18n.locale = :es
        end
      end
    else
      I18n.locale = params[:locale]
    end
  end

  def request_location
    if Rails.env.test? || Rails.env.development?
      return "CO"
    else
      if request.location
        return request.location.country_code
      else
        return nil
      end
    end
  end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

  def constraint_locale
    unless Country.all.pluck(:locale).include? (I18n.locale.to_s)
      redirect_to landing_path(redirect_params: params.inspect)
    end
  end

  def permitted_params
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  
  def quick_add
    @due_payment = false
    if current_user && (current_user.role_id != Role.find_by_name("Super Admin").id) && current_user.company_id
      company = Company.find(current_user.company_id)
      if company.payment_status == PaymentStatus.find_by_name("Bloqueado") || !company.active
        if current_user.role_id == Role.find_by_name("Administrador General").id
          redirect_to select_plan_path, notice: "¡Activa tu cuenta AgendaPro! No te pierdas un segundo más el acceso a las increíbles oportunidades que te da tu cuenta AgendaPro."
        else
          redirect_to dashboard_path, notice: "¡Activa tu cuenta AgendaPro! No te pierdas un segundo más el acceso a las oportunidades que te da tu cuenta AgendaPro. Si no eres el administrador, ponte en contacto con él para activar la cuenta."
        end
      elsif company.economic_sectors.count == 0
        redirect_to(quick_add_path)
      elsif company.locations.count == 0
        redirect_to(quick_add_path(:step => 1))
      elsif company.services.count == 0
        redirect_to(quick_add_path(:step => 2))
      elsif company.service_providers.count == 0
        redirect_to(quick_add_path(:step => 3))
      elsif company.payment_status == PaymentStatus.find_by_name("Vencido")
        @due_payment = true
      end
    end
  end

  def verify_is_active
    @company = Company.find_by(web_address: request.subdomain)
    if @company && ( !@company.active || !@company.owned)
      redirect_to "/307" unless current_user && (current_user.role_id == Role.find_by_name("Super Admin").id)
    end
  end

  def verify_is_super_admin
    host = request.host_with_port
    @url = host[host.index(request.domain)..host.length]
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Super Admin").id)
  end

  def verify_is_admin
    host = request.host_with_port
    @url = host[host.index(request.domain)..host.length]
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Administrador General").id)
  end

  def verify_is_local_admin
    host = request.host_with_port
    @url = host[host.index(request.domain)..host.length]
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Administrador Local").id)
  end

  def verify_is_staff
    host = request.host_with_port
    @url = host[host.index(request.domain)..host.length]
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Staff").id)
  end

  def verify_is_user
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Usuario Registrado").id)
  end

  private

  def after_sign_out_path_for(resource_or_scope)
    localized_root_path
  end

  def after_sign_in_path_for(resource)
    if current_user && current_user.company_id && current_user.company_id > 0
      if current_user.company.country && current_user.company.country.locale
        dashboard_path(locale: current_user.company.country.locale)
      else
        dashboard_path
      end
    else
      if request.env['omniauth.origin']
        begin
          url = request.env['omniauth.origin'].gsub(localized_root_path)
          Rails.application.routes.recognize_path(url)
          request.env['omniauth.origin']
        rescue
          localized_root_path
        end
      elsif stored_location_for(resource)
        begin 
          url = stored_location_for(resource).gsub(localized_root_path)
          Rails.application.routes.recognize_path(url)
          stored_location_for(resource)
        rescue
          localized_root_path
        end
      else
        localized_root_path
      end
    end
  end

  def after_sign_up_path_for(resource)
    if current_user && current_user.company_id && current_user.company_id > 0
      if current_user.company.country && current_user.company.country.locale
        dashboard_path(locale: current_user.company.country.locale)
      else
        dashboard_path
      end
    else
      localized_root_path
    end
  end

end
