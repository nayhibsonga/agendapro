class ApplicationController < ActionController::Base

	layout "login" #:layout

	include UrlHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Mobu::DetectMobile

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "/403"
  end

  protected
  
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
    if @company && !@company.active
      redirect_to "/307" unless current_user && (current_user.role_id == Role.find_by_name("Super Admin").id)
    end
  end

  def verify_is_super_admin
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Super Admin").id)
  end

  def verify_is_admin
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Administrador General").id)
  end

  def verify_is_local_admin
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Administrador Local").id)
  end

  def verify_is_staff
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Staff").id)
  end

  def verify_is_user
    redirect_to "/403" unless (current_user.role_id == Role.find_by_name("Usuario Registrado").id)
  end

  private

  private 

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

end
